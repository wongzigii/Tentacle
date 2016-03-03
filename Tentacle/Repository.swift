//
//  Repository.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation


/// A GitHub.com or GitHub Enterprise repository.
public struct Repository: Hashable, CustomStringConvertible {
    public let server: Server
    public let owner: String
    public let name: String
    
    public init(server: Server = .DotCom, owner: String, name: String) {
        self.server = server
        self.owner = owner
        self.name = name
    }
    
    /// The URL of the repository.
    public var URL: NSURL {
        return server.URL
            .URLByAppendingPathComponent(owner)
            .URLByAppendingPathComponent(name)
    }
    
    public var hashValue: Int {
        return URL.hashValue
    }
    
    public var description: String {
        return "\(URL)"
    }
}

public func ==(lhs: Repository, rhs: Repository) -> Bool {
    return lhs.server == rhs.server
        && lhs.owner == rhs.owner
        && lhs.name == rhs.name
}
