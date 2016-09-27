//
//  Server.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation


/// A GitHub.com or GitHub Enterprise server.
public enum Server: Hashable, CustomStringConvertible {
    /// The GitHub.com server.
    case DotCom
    
    /// A GitHub Enterprise server.
    case Enterprise(url: NSURL)
    
    /// The URL of the server.
    public var URL: NSURL {
        switch self {
        case .DotCom:
            return NSURL(string: "https://github.com")!
        
        case let .Enterprise(url):
            return url
        }
    }
    
    internal var endpoint: String {
        switch self {
        case .DotCom:
            return "https://api.github.com"
            
        case let .Enterprise(url):
            #if swift(>=2.3)
                return "\(url.scheme!)://\(url.host!)/api/v3"
            #else
                return "\(url.scheme)://\(url.host!)/api/v3"
            #endif
        }
    }
    
    public var hashValue: Int {
        return endpoint.lowercaseString.hashValue
    }
    
    public var description: String {
        return "\(URL)"
    }
}

public func ==(lhs: Server, rhs: Server) -> Bool {
    switch (lhs, rhs) {
    case (.DotCom, .DotCom):
        return true
    
    case (.Enterprise, .Enterprise):
        return lhs.endpoint.caseInsensitiveCompare(rhs.endpoint) == .OrderedSame
        
    default:
        return false
    }
}
