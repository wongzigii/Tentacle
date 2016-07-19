//
//  PullRequest.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct PullRequest: Hashable, CustomStringConvertible {
    public let URL: NSURL
    public let diffURL: NSURL
    public let patchURL: NSURL

    public var hashValue: Int {
        return URL.hashValue
    }

    public var description: String {
        return URL.absoluteString
    }
}

public func ==(lhs: PullRequest, rhs: PullRequest) -> Bool {
    return lhs.URL == rhs.URL
}

extension PullRequest: ResourceType {
    public static func decode(j: JSON) -> Decoded<PullRequest> {
        return curry(self.init)
            <^> (j <| "html_url" >>- toNSURL)
            <*> (j <| "diff_url" >>- toNSURL)
            <*> (j <| "patch_url" >>- toNSURL)

    }
}