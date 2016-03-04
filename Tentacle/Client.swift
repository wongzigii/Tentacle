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
    internal static func deserializeJSON(data: NSData) -> Result<NSDictionary, NSError> {
        return Result(try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary)
    }
}

extension NSURLRequest {
    internal static func create(server: Server, _ endpoint: Client.Endpoint) -> NSURLRequest {
        let URL = NSURL(string: server.endpoint)!.URLByAppendingPathComponent(endpoint.path)
        return NSURLRequest(URL: URL)
    }
}

/// A GitHub API Client
public final class Client {
    /// An error from the Client.
    public enum Error: ErrorType {
        /// An error occurred in a network operation.
        case NetworkError(NSError)
        
        /// An error occurred while deserializing JSON.
        case JSONDeserializationError(NSError)
        
        /// An error occurred while decoding JSON.
        case JSONDecodingError(DecodeError)
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
    
    /// The Server that the Client connects to.
    public let server: Server
    
    /// Create an unauthenticated client for the given Server.
    public init(_ server: Server) {
        self.server = server
    }
    
    /// Fetch the release corresponding to the given tag in the given repository.
    public func releaseForTag(tag: String, inRepository repository: Repository) -> SignalProducer<Release, Error> {
        precondition(repository.server == server)
        return fetchOne(Endpoint.ReleaseByTagName(owner: repository.owner, repository: repository.name, tag: tag))
    }
    
    /// Fetch an object from the API.
    internal func fetchOne<Object: Decodable where Object.DecodedType == Object>(endpoint: Endpoint) -> SignalProducer<Object, Error> {
        return NSURLSession
            .sharedSession()
            .rac_dataWithRequest(NSURLRequest.create(server, endpoint))
            .mapError(Error.NetworkError)
            .flatMap(FlattenStrategy.Concat) { data, response in
                return SignalProducer
                    .attempt { NSJSONSerialization.deserializeJSON(data) }
                    .mapError(Error.JSONDeserializationError)
            }
            .attemptMap { JSON in
                switch Object.decode(.parse(JSON)) {
                case let .Success(object):
                    return .Success(object)
                case let .Failure(error):
                    return .Failure(.JSONDecodingError(error))
                }
            }
    }
}

internal func ==(lhs: Client.Endpoint, rhs: Client.Endpoint) -> Bool {
    switch (lhs, rhs) {
    case let (.ReleaseByTagName(owner1, repo1, tag1), .ReleaseByTagName(owner2, repo2, tag2)):
        return owner1 == owner2 && repo1 == repo2 && tag1 == tag2
    }
}
