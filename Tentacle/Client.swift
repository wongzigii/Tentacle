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


extension Decodable {
    internal static func decode(JSON: NSDictionary) -> Result<DecodedType, DecodeError> {
        switch decode(.parse(JSON)) {
        case let .Success(object):
            return .Success(object)
        case let .Failure(error):
            return .Failure(error)
        }
    }
}

extension DecodeError: Hashable {
    public var hashValue: Int {
        switch self {
        case let .TypeMismatch(expected: expected, actual: actual):
            return expected.hashValue ^ actual.hashValue
            
        case let .MissingKey(string):
            return string.hashValue
            
        case let .Custom(string):
            return string.hashValue
        }
    }
}

public func ==(lhs: DecodeError, rhs: DecodeError) -> Bool {
    switch (lhs, rhs) {
    case let (.TypeMismatch(expected: expected1, actual: actual1), .TypeMismatch(expected: expected2, actual: actual2)):
        return expected1 == expected2 && actual1 == actual2
        
    case let (.MissingKey(string1), .MissingKey(string2)):
        return string1 == string2
        
    case let (.Custom(string1), .Custom(string2)):
        return string1 == string2
        
    default:
        return false
    }
}

extension NSJSONSerialization {
    internal static func deserializeJSON(data: NSData) -> Result<NSDictionary, NSError> {
        return Result(try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary)
    }
}

extension NSURLRequest {
    internal static func create(server: Server, _ endpoint: Client.Endpoint, _ credentials: Client.Credentials?) -> NSURLRequest {
        let URL = NSURL(string: server.endpoint)!.URLByAppendingPathComponent(endpoint.path)
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
        
        /// A status code and error that was returned from the API.
        case APIError(Int, GitHubError)
        
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
                
            case let .APIError(statusCode, error):
                return statusCode.hashValue ^ error.hashValue
                
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
        case ReleaseByTagName(owner: String, repository: String, tag: String)
        
        var path: String {
            switch self {
            case let .ReleaseByTagName(owner, repo, tag):
                return "/repos/\(owner)/\(repo)/releases/tags/\(tag)"
            }
        }
        
        var hashValue: Int {
            switch self {
            case let .ReleaseByTagName(owner, repo, tag):
                return owner.hashValue ^ repo.hashValue ^ tag.hashValue
            }
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
    
    /// Fetch the release corresponding to the given tag in the given repository.
    ///
    /// If the tag exists, but there's not a correspoding GitHub Release, this method will return a
    /// `.DoesNotExist` error. This is indistinguishable from a nonexistent tag.
    public func releaseForTag(tag: String, inRepository repository: Repository) -> SignalProducer<Release, Error> {
        precondition(repository.server == server)
        return fetchOne(Endpoint.ReleaseByTagName(owner: repository.owner, repository: repository.name, tag: tag))
    }
    
    /// Fetch an object from the API.
    internal func fetchOne<Object: Decodable where Object.DecodedType == Object>(endpoint: Endpoint) -> SignalProducer<Object, Error> {
        return NSURLSession
            .sharedSession()
            .rac_dataWithRequest(NSURLRequest.create(server, endpoint, credentials))
            .mapError(Error.NetworkError)
            .flatMap(.Concat) { data, response -> SignalProducer<Object, Error> in
                let response = response as! NSHTTPURLResponse
                return SignalProducer
                    .attempt {
                        return NSJSONSerialization.deserializeJSON(data).mapError(Error.JSONDeserializationError)
                    }
                    .attemptMap { JSON in
                        if response.statusCode == 404 {
                            return .Failure(.DoesNotExist)
                        }
                        if response.statusCode >= 400 && response.statusCode < 600 {
                            return GitHubError.decode(JSON)
                                .mapError(Error.JSONDecodingError)
                                .flatMap { .Failure(Error.APIError(response.statusCode, $0)) }
                        }
                        return Object.decode(JSON).mapError(Error.JSONDecodingError)
                    }
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
        
    case let (.APIError(statusCode1, error1), .APIError(statusCode2, error2)):
        return statusCode1 == statusCode2 && error1 == error2
        
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
    }
}
