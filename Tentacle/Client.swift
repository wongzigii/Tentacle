//
//  Client.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Foundation
import ReactiveCocoa
import Result


extension NSJSONSerialization {
    internal static func deserializeJSON(data: NSData) -> Result<AnyObject, NSError> {
        return Result(try NSJSONSerialization.JSONObjectWithData(data, options: []))
    }
}

extension NSURL {
    internal func URLWithQueryItems(queryItems: [NSURLQueryItem]) -> NSURL {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: true)!
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.URL!
    }
    
    internal convenience init(_ server: Server, _ endpoint: Client.Endpoint, page: UInt? = nil, pageSize: UInt? = nil) {
        let queryItems = [ ("page", page), ("per_page", pageSize) ]
            .filter { _, value in value != nil }
            .map { name, value in NSURLQueryItem(name: name, value: "\(value!)") }
        
        let URL = NSURL(string: server.endpoint)!
            .URLByAppendingPathComponent(endpoint.path)
            .URLWithQueryItems(endpoint.queryItems)
            .URLWithQueryItems(queryItems)
        
        self.init(string: URL.absoluteString)!
    }
}

extension NSURLRequest {
    internal static func create(URL: NSURL, _ credentials: Client.Credentials?) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        if let userAgent = Client.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        if let credentials = credentials {
            request.setValue(credentials.authorizationHeader, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}

/// A GitHub API Client
public final class Client {
    /// An error from the Client.
    public enum Error: Hashable, ErrorType {
        /// An error occurred in a network operation.
        case NetworkError(NSError)
        
        /// An error occurred while deserializing JSON.
        case JSONDeserializationError(NSError)
        
        /// An error occurred while decoding JSON.
        case JSONDecodingError(DecodeError)
        
        /// A status code, response, and error that was returned from the API.
        case APIError(Int, Response, GitHubError)
        
        /// The requested object does not exist.
        case DoesNotExist
        
        public var hashValue: Int {
            switch self {
            case let .NetworkError(error):
                return error.hashValue
                
            case let .JSONDeserializationError(error):
                return error.hashValue
                
            case let .JSONDecodingError(error):
                return error.hashValue
                
            case let .APIError(statusCode, response, error):
                return statusCode.hashValue ^ response.hashValue ^ error.hashValue
                
            case .DoesNotExist:
                return 4
            }
        }
    }
    
    /// Credentials for the GitHub API.
    internal enum Credentials {
        case Token(String)
        case Basic(username: String, password: String)
        
        var authorizationHeader: String {
            switch self {
            case let .Token(token):
                return "token \(token)"
            case let .Basic(username, password):
                let data = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
                let encodedString = data.base64EncodedStringWithOptions([])
                return "Basic \(encodedString)"
            }
        }
    }
    
    /// A GitHub API endpoint.
    internal enum Endpoint: Hashable {
        // https://developer.github.com/v3/repos/releases/#get-a-release-by-tag-name
        case ReleaseByTagName(owner: String, repository: String, tag: String)
        
        // https://developer.github.com/v3/repos/releases/#list-releases-for-a-repository
        case ReleasesInRepository(owner: String, repository: String)
        
        var path: String {
            switch self {
            case let .ReleaseByTagName(owner, repo, tag):
                return "/repos/\(owner)/\(repo)/releases/tags/\(tag)"
            case let .ReleasesInRepository(owner, repo):
                return "/repos/\(owner)/\(repo)/releases"
            }
        }
        
        var hashValue: Int {
            switch self {
            case let .ReleaseByTagName(owner, repo, tag):
                return owner.hashValue ^ repo.hashValue ^ tag.hashValue
            case let .ReleasesInRepository(owner, repo):
                return owner.hashValue ^ repo.hashValue
            }
        }
        
        var queryItems: [NSURLQueryItem] {
            return []
        }
    }
    
    /// The user-agent to use for API requests.
    public static var userAgent: String?
    
    /// The Server that the Client connects to.
    public let server: Server
    
    /// The Credentials for the API.
    private let credentials: Credentials?
    
    /// Create an unauthenticated client for the given Server.
    public init(_ server: Server) {
        self.server = server
        self.credentials = nil
    }
    
    /// Create an authenticated client for the given Server with a token.
    public init(_ server: Server, token: String) {
        self.server = server
        self.credentials = .Token(token)
    }
    
    /// Create an authenticated client for the given Server with a username and password.
    public init(_ server: Server, username: String, password: String) {
        self.server = server
        self.credentials = .Basic(username: username, password: password)
    }
    
    /// Fetch the releases in the given repository, starting at the given page.
    ///
    /// This method will automatically fetch all pages. Each value in the returned signal producer
    /// will be the response and releases from a single page.
    ///
    /// https://developer.github.com/v3/repos/releases/#list-releases-for-a-repository
    public func releasesInRepository(repository: Repository, page: UInt = 1, perPage: UInt = 30) -> SignalProducer<(Response, [Release]), Error> {
        precondition(repository.server == server)
        return fetchMany(Endpoint.ReleasesInRepository(owner: repository.owner, repository: repository.name), page: page, pageSize: perPage)
    }
    
    /// Fetch the release corresponding to the given tag in the given repository.
    ///
    /// If the tag exists, but there's not a correspoding GitHub Release, this method will return a
    /// `.DoesNotExist` error. This is indistinguishable from a nonexistent tag.
    public func releaseForTag(tag: String, inRepository repository: Repository) -> SignalProducer<(Response, Release), Error> {
        precondition(repository.server == server)
        return fetchOne(Endpoint.ReleaseByTagName(owner: repository.owner, repository: repository.name, tag: tag))
    }
    
    /// Fetch an endpoint from the API.
    private func fetch(endpoint: Endpoint, page: UInt?, pageSize: UInt?) -> SignalProducer<(Response, AnyObject), Error> {
        let URL = NSURL(server, endpoint, page: page, pageSize: pageSize)
        let request = NSURLRequest.create(URL, credentials)
        return NSURLSession
            .sharedSession()
            .rac_dataWithRequest(request)
            .mapError(Error.NetworkError)
            .flatMap(.Concat) { data, response -> SignalProducer<(Response, AnyObject), Error> in
                let response = response as! NSHTTPURLResponse
                let headers = response.allHeaderFields as! [String:String]
                return SignalProducer
                    .attempt {
                        return NSJSONSerialization.deserializeJSON(data).mapError(Error.JSONDeserializationError)
                    }
                    .attemptMap { JSON in
                        if response.statusCode == 404 {
                            return .Failure(.DoesNotExist)
                        }
                        if response.statusCode >= 400 && response.statusCode < 600 {
                            return decode(JSON)
                                .mapError(Error.JSONDecodingError)
                                .flatMap { error in
                                    .Failure(Error.APIError(response.statusCode, Response(headerFields: headers), error))
                                }
                        }
                        return .Success(JSON)
                    }
                    .map { JSON in
                        return (Response(headerFields: headers), JSON)
                    }
            }
    }
    
    /// Fetch an object from the API.
    internal func fetchOne
        <Resource: ResourceType where Resource.DecodedType == Resource>
        (endpoint: Endpoint) -> SignalProducer<(Response, Resource), Error>
    {
        return fetch(endpoint, page: nil, pageSize: nil)
            .attemptMap { response, JSON in
                return decode(JSON)
                    .map { resource in
                        (response, resource)
                    }
                    .mapError(Error.JSONDecodingError)
            }
    }
    
    /// Fetch a list of objects from the API.
    internal func fetchMany
        <Resource: ResourceType where Resource.DecodedType == Resource>
        (endpoint: Endpoint, page: UInt?, pageSize: UInt?) -> SignalProducer<(Response, [Resource]), Error>
    {
        let nextPage = (page ?? 1) + 1
        return fetch(endpoint, page: page, pageSize: pageSize)
            .attemptMap { response, JSON in
                return decode(JSON)
                    .map { resource in
                        (response, resource)
                    }
                    .mapError(Error.JSONDecodingError)
            }
            .flatMap(.Concat) { response, JSON -> SignalProducer<(Response, [Resource]), Error> in
                return SignalProducer(value: (response, JSON))
                    .concat(response.links["next"] == nil ? SignalProducer.empty : self.fetchMany(endpoint, page: nextPage, pageSize: pageSize))
            }
    }
}

public func ==(lhs: Client.Error, rhs: Client.Error) -> Bool {
    switch (lhs, rhs) {
    case let (.NetworkError(error1), .NetworkError(error2)):
        return error1 == error2
        
    case let (.JSONDeserializationError(error1), .JSONDeserializationError(error2)):
        return error1 == error2
        
    case let (.JSONDecodingError(error1), .JSONDecodingError(error2)):
        return error1 == error2
        
    case let (.APIError(statusCode1, response1, error1), .APIError(statusCode2, response2, error2)):
        return statusCode1 == statusCode2 && response1 == response2 && error1 == error2
        
    case (.DoesNotExist, .DoesNotExist):
        return true
        
    default:
        return false
    }
}

internal func ==(lhs: Client.Endpoint, rhs: Client.Endpoint) -> Bool {
    switch (lhs, rhs) {
    case let (.ReleaseByTagName(owner1, repo1, tag1), .ReleaseByTagName(owner2, repo2, tag2)):
        return owner1 == owner2 && repo1 == repo2 && tag1 == tag2
    case let (.ReleasesInRepository(owner1, repo1), .ReleasesInRepository(owner2, repo2)):
        return owner1 == owner2 && repo1 == repo2
    default:
        return false
    }
}
