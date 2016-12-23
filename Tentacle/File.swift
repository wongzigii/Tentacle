//
//  File.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-12-21.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Ogra
import Argo
import Runes
import Curry

public struct File {
    public let message: String
    public let committer: Author?
    public let author: Author?
    public let content: Data
    public let branch: String?
}

extension File: RequestType {
    public typealias Response = FileResponse

    public var hashValue: Int {
        return message.hashValue
    }

    public func encode() -> JSON {
        return JSON.object([
            "message": self.message.encode(),
            "committer": self.committer?.encode() ?? .null,
            "author": self.committer?.encode() ?? .null,
            "content": self.content.base64EncodedString().encode(),
            "branch": self.branch?.encode() ?? .null
        ])
    }

    public static func ==(lhs: File, rhs: File) -> Bool {
        return lhs.message == rhs.message
            && lhs.committer == rhs.committer
            && lhs.author == rhs.committer
            && lhs.content == rhs.content
            && lhs.branch == rhs.branch
    }
}
