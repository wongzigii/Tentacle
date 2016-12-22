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

struct Author {
    let name: String
    let email: String
}

extension Author: Encodable {
    func encode() -> JSON {
        return JSON.object([
            "name": self.name.encode(),
            "email": self.email.encode()
        ])
    }
}

extension Author: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue ^ email.hashValue
    }

    static func ==(lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
            && lhs.email == rhs.email
    }
}

struct File {
    let message: String
    let committer: Author?
    let author: Author?
    let content: Data
    let branch: String?
}

struct FileResponse {
    let content: Content
    let commit: Commit
}

extension FileResponse: ResourceType {
    static func decode(_ j: JSON) -> Decoded<FileResponse> {
        return curry(FileResponse.init)
            <^> j <| "content"
            <*> j <| "commit"
    }

    var hashValue: Int {
        return content.hashValue ^ commit.hashValue
    }

    static func ==(lhs: FileResponse, rhs: FileResponse) -> Bool {
        return true
    }
}

extension File: InputType {
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
