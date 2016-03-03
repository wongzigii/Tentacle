//
//  Client.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import ReactiveCocoa


/// A GitHub API Client
public final class Client {
    /// An error from the Client.
    public enum Error: ErrorType {
        /// An error occurred in a network operation.
        case NetworkError(NSError)
    }
    
    /// A GitHub API endpoint.
    internal enum Endpoint {
        case ReleaseByTagName(owner: String, repository: String, tag: String)
        
        var path: String {
            switch self {
            case let .ReleaseByTagName(owner, repo, tag):
                return "/repos/\(owner)/\(repo)/releases/tags/\(tag)"
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
