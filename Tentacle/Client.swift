//
//  Client.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import ReactiveCocoa


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
    public init(server: Server) {
        self.server = server
    }
}

internal func ==(lhs: Client.Endpoint, rhs: Client.Endpoint) -> Bool {
    switch (lhs, rhs) {
    case let (.ReleaseByTagName(owner1, repo1, tag1), .ReleaseByTagName(owner2, repo2, tag2)):
        return owner1 == owner2 && repo1 == repo2 && tag1 == tag2
    }
}
