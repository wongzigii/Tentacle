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
            case file(size: Int, downloadURL: URL)
            case directory
            case symlink(target: String, downloadURL: URL?)
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

        public var description: String {
            return name
        }

    }

    case file(File)
    case directory([File])
}

func decodeFile(_ payload: [String: JSON]) -> Decoded<Content.File.ContentType> {
    guard let sizeNode = payload["size"] else {
        return .failure(.missingKey("size"))
    }

    guard case let .number(size) = sizeNode else {
        return .failure(.typeMismatch(expected: "number", actual: "\(sizeNode)"))
    }

    guard let downloadURLNode = payload["download_url"] else {
        return .failure(.missingKey("download_url"))
    }

    guard case let .string(content) = downloadURLNode, let downloadURL = URL(string: content) else {
        return .failure(.typeMismatch(expected: "string", actual: "\(downloadURLNode)"))
    }

    return .success(Content.File.ContentType.file(size: size.intValue, downloadURL: downloadURL))
}

func decodeSymlink(_ payload: [String: JSON]) -> Decoded<Content.File.ContentType> {
    guard let targetNode = payload["target"] else {
        return .failure(.missingKey("target"))
    }

    guard case let .string(target) = targetNode else {
        return .failure(.typeMismatch(expected: "string", actual: "\(targetNode)"))
    }

    guard let downloadURLNode = payload["download_url"] else {
        return .failure(.missingKey("download_url"))
    }

    guard case let .string(content) = downloadURLNode else {
        return .failure(.typeMismatch(expected: "string", actual: "\(downloadURLNode)"))
    }


    return .success(Content.File.ContentType.symlink(target: target, downloadURL: URL(string: content)))
}

func decodeSubmodule(_ payload: [String: JSON]) -> Decoded<Content.File.ContentType> {
    guard let urlNode = payload["submodule_git_url"] else {
        return .failure(.missingKey("submodule_git_url"))
    }

    guard case let .string(url) = urlNode else {
        return .failure(.typeMismatch(expected: "string", actual: "\(urlNode)"))
    }

    return .success(Content.File.ContentType.submodule(url: url))
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
            return decodeFile(payload)
        case "directory":
            return .success(Content.File.ContentType.directory)
        case "submodule":
            return decodeSubmodule(payload)
        case "symlink":
            return decodeSymlink(payload)
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

extension Content.File.ContentType: Equatable {
    public static func ==(lhs: Content.File.ContentType, rhs: Content.File.ContentType) -> Bool {
        switch (lhs, rhs) {
        case let (.file(size, url), .file(size2, url2)) where size == size2 && url == url2: return true
        case (.directory, .directory): return true
        case let (.submodule(url), .submodule(url2)) where url == url2: return true
        case let (.symlink(target, url), .symlink(target2, url2)) where target == target2 && url == url2: return true
        default: return false
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
            && lhs.content == rhs.content
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
    }
}
