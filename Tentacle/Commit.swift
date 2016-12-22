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

struct Commit {
    let sha: String
}

extension Commit: ResourceType {
    var hashValue: Int {
        return sha.hashValue
    }

    static func ==(lhs: Commit, rhs: Commit) -> Bool {
        return lhs.sha == rhs.sha
    }

    static func decode(_ j: JSON) -> Decoded<Commit> {
        return curry(Commit.init)
            <^> (j <| "sha")
    }
}
