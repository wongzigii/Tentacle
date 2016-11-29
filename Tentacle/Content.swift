//
//  Content.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-11-28.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct Content: CustomStringConvertible {
    public enum ContentType: String {
        case file
        case dir
        case symlink
    }

    /// The type of content
    public let type: ContentType

    /// Path to actual content when content is a symlink
    public let target: String?

    /// Size when content is a file
    public let size: Int

    /// Name of the file
    public let name: String

    /// Path to the file in repository
    public let path: String

    /// Sha of the file
    public let sha: String

    /// URL to preview the content
    public let url: URL

    /// URL to download the content when content is a file or content is a symlink to a file
    public let downloadURL: URL?

    public var description: String {
        return name
    }

}

extension Content: Hashable {
    public static func ==(lhs: Content, rhs: Content) -> Bool {
        return lhs.name == rhs.name
    }

    public var hashValue: Int {
        return name.hashValue
    }
}


internal func toContentType(_ string: String) -> Decoded<Content.ContentType> {
    if let content = Content.ContentType(rawValue: string) {
        return .success(content)
    } else {
        return .failure(.custom("Content type is invalid"))
    }
}

extension Content: ResourceType {
    public static func decode(_ j: JSON) -> Decoded<Content> {
        let f = curry(Content.init)

        return f
            <^> (j <| "type" >>- toContentType)
            <*> j <|? "target"
            <*> j <| "size"
            <*> j <| "name"
            <*> j <| "path"
            <*> j <| "sha"
            <*> (j <| "html_url" >>- toURL)
            <*> (j <|? "download_url" >>- toOptionalURL)
    }
}
