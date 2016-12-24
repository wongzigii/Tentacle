//
//  Commit.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-12-22.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct Commit {
    /// SHA of the commit
    public let sha: String
}

extension Commit: ResourceType {
    public var hashValue: Int {
        return sha.hashValue
    }

    public static func ==(lhs: Commit, rhs: Commit) -> Bool {
        return lhs.sha == rhs.sha
    }

    public static func decode(_ j: JSON) -> Decoded<Commit> {
        return curry(Commit.init)
            <^> (j <| "sha")
    }
}
