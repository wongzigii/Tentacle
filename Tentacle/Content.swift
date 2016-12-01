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

public enum Content {
    public struct File: CustomStringConvertible {
        public enum ContentType: String {
            case file
            case dir
            case symlink
            case submodule
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

    case file(File)
    case directory([File])
}

extension Content: Hashable {
    public static func ==(lhs: Content, rhs: Content) -> Bool {
        switch (lhs, rhs) {
        case let (.file(file1), .file(file2)) where file1 == file2: return true
        case let (.directory(dir1), .directory(dir2)) where dir1 == dir2: return true
        default: return false
        }
    }

    public var hashValue: Int {
        switch self {
        case .file(let file):
            return "file".hashValue ^ file.hashValue
        case .directory(let files):
            return files.reduce("directory".hashValue) { $0.hashValue ^ $1.hashValue }
        }
    }
}

extension Content: ResourceType {
    public static func decode(_ j: JSON) -> Decoded<Content> {

        switch j {
        case .array(_):
            switch Array<Content.File>.decode(j) {
            case let .success(decoded):
                return .success(Content.directory(decoded))
            case let .failure(error):
                return .failure(.custom("\(error)"))
            }
        case .object(_):
            switch Content.File.decode(j) {
            case let .success(decoded):
                return .success(Content.file(decoded))
            case let .failure(error):
                return .failure(.custom("\(error)"))
            }
        default:
            return .failure(.typeMismatch(expected: "", actual: "\(j)"))
        }

    }
}

extension Content.File: Hashable {
    public static func ==(lhs: Content.File, rhs: Content.File) -> Bool {
        return lhs.name == rhs.name
            && lhs.path == rhs.path
            && lhs.sha == rhs.sha
    }

    public var hashValue: Int {
        return name.hashValue
    }
}


internal func toContentType(_ string: String) -> Decoded<Content.File.ContentType> {
    if let content = Content.File.ContentType(rawValue: string) {
        return .success(content)
    } else {
        return .failure(.custom("Content type is invalid"))
    }
}

extension Content.File: ResourceType {
    public static func decode(_ j: JSON) -> Decoded<Content.File> {
        let f = curry(Content.File.init)

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
