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

struct File {
    let message: String
    let committer: Author?
    let author: Author?
    let content: Data
    let branch: String?
}

extension File: RequestType {
    typealias Response = FileResponse

    var hashValue: Int {
        return message.hashValue
    }

    func encode() -> JSON {
        return JSON.object([
            "message": self.message.encode(),
            "committer": self.committer?.encode() ?? .null,
            "author": self.committer?.encode() ?? .null,
            "content": self.content.base64EncodedString().encode(),
            "branch": self.branch?.encode() ?? .null
        ])
    }

    static func ==(lhs: File, rhs: File) -> Bool {
        return lhs.message == rhs.message
            && lhs.committer == rhs.committer
            && lhs.author == rhs.committer
            && lhs.content == rhs.content
            && lhs.branch == rhs.branch
    }
}
