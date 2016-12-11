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
        public enum ContentType {
            case file(size: Int)
            case directory
            case symlink(target: String)
            case submodule(url: String)
        }

        /// The type of content
        public let content: ContentType

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

extension Content.File.ContentType: Decodable {
    public static func decode(_ json: JSON) -> Decoded<Content.File.ContentType> {
        guard case let .object(payload) = json else {
            return .failure(.typeMismatch(expected: "object", actual: "\(json)"))
        }

        guard let type = payload["type"], case let .string(value) = type else {
            return .failure(.custom("Content type is invalid"))
        }

        switch value {
        case "file":
            guard let sizeNode = payload["size"] else {
                return .failure(.missingKey("size"))
            }

            guard case let .number(size) = sizeNode else {
                return .failure(.typeMismatch(expected: "number", actual: "\(sizeNode)"))
            }
            return .success(Content.File.ContentType.file(size: size.intValue))

        case "directory":
            return .success(Content.File.ContentType.directory)

        case "submodule":
            guard let urlNode = payload["submodule_git_url"] else {
                return .failure(.missingKey("submodule_git_url"))
            }

            guard case let .string(url) = urlNode else {
                return .failure(.typeMismatch(expected: "string", actual: "\(urlNode)"))
            }
            return .success(Content.File.ContentType.submodule(url: url))

        case "symlink":
            guard let targetNode = payload["target"] else {
                return .failure(.missingKey("target"))
            }

            guard case let .string(target) = targetNode else {
                return .failure(.typeMismatch(expected: "string", actual: "\(targetNode)"))
            }
            return .success(Content.File.ContentType.symlink(target: target))
        default:
            return .failure(.custom("Content type \(value) is invalid"))
        }
    }
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

extension Content.File: ResourceType {
    public static func decode(_ j: JSON) -> Decoded<Content.File> {
        let f = curry(Content.File.init)

        return f
            <^> Content.File.ContentType.decode(j)
            <*> j <| "name"
            <*> j <| "path"
            <*> j <| "sha"
            <*> (j <| "html_url" >>- toURL)
            <*> (j <|? "download_url" >>- toOptionalURL)
    }
}
