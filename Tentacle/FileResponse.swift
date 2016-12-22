//
//  FileResponse.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-12-22.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

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
