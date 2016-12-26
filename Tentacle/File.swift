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
    /// Commit message
    public let message: String
    /// The committer of the commit
    public let committer: Author?
    /// The author of the commit
    public let author: Author?
    /// Content of the file to create
    public let content: Data
    /// Branch in which the file will be created
    public let branch: String?

    public init(message: String, committer: Author?, author: Author?, content: Data, branch: String?) {
        self.message = message
        self.committer = committer
        self.author = author
        self.content = content
        self.branch = branch
    }
}

extension File: RequestType {
    public typealias Response = FileResponse

    public var hashValue: Int {
        return message.hashValue
    }

    public var method: HTTPMethod {
        return .put
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
