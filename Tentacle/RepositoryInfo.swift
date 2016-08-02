//
//  RepositoryInfo.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-08-02.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public struct RepositoryInfo: Hashable, CustomStringConvertible {
    let id: String
    let owner: Owner

    let name: String
    let fullName: String
    let body: String
    let URL: NSURL
    let homepage: NSURL

    let isPrivate: Bool
    let isFork: Bool

    let forksCount: Int
    let stargazersCount: Int
    let watchersCount: Int
    let openIssuesCount: Int
    let size: Int
    let defaultBranch: String

    let language: String?
    let hasIssues: Bool
    let hasWiki: Bool
    let hasPages: Bool
    let hasDownloads: Bool

    let pushedAt: NSDate
    let createdAt: NSDate
    let updatedAt: NSDate

    public var hashValue: Int {
        return id.hashValue ^ fullName.hashValue
    }

    public var description: String {
        return fullName
    }
}

public func ==(lhs: RepositoryInfo, rhs: RepositoryInfo) -> Bool {
    return lhs.id == rhs.id
        && lhs.name == rhs.id
        && lhs.fullName == rhs.fullName
}
