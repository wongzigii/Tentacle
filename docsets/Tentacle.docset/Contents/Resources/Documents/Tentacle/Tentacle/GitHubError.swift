//
//  GitHubError.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/4/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Curry
import Foundation


/// An error from the GitHub API.
public struct GitHubError: Hashable, CustomStringConvertible, ErrorType {
    /// The error message from the API.
    public let message: String
    
    public var hashValue: Int {
        return message.hashValue
    }
    
    public var description: String {
        return message
    }
    
    public init(message: String) {
        self.message = message
    }
}

public func ==(lhs: GitHubError, rhs: GitHubError) -> Bool {
    return lhs.message == rhs.message
}

extension GitHubError: Decodable {
    public static func decode(j: JSON) -> Decoded<GitHubError> {
        return curry(self.init) <^> j <| "message"
    }
}
