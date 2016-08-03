//
//  RepositoryInfo.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-08-02.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct RepositoryInfo: Hashable, CustomStringConvertible {
    let id: String
    let owner: Owner

    let name: String
    let fullName: String
    let body: String
    let URL: NSURL
    let homepage: NSURL?

    let isPrivate: Bool
    let isFork: Bool

    let forksCount: Int
    let stargazersCount: Int
    let watchersCount: Int
    let openIssuesCount: Int
    let size: Int
    let defaultBranch: String

    let pushedAt: NSDate
    let createdAt: NSDate
    let updatedAt: NSDate

    public var hashValue: Int {
        return id.hashValue //^ fullName.hashValue
    }

    public var description: String {
        return fullName
    }
}

public func ==(lhs: RepositoryInfo, rhs: RepositoryInfo) -> Bool {
    return lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.fullName == rhs.fullName
}

extension RepositoryInfo: ResourceType {
    public static func decode(j: JSON) -> Decoded<RepositoryInfo> {
        let f = curry(RepositoryInfo.init)

        return f
            <^> (j <| "id" >>- toString)
            <*> j <| "owner"
            <*> j <| "name"
            <*> j <| "full_name"
            <*> j <| "description"
            <*> (j <| "html_url" >>- toNSURL)
            <*> (j <|? "homepage" >>- toOptionalNSURL)
            <*> j <| "private"
            <*> j <| "fork"
            <*> j <| "forks_count"
            <*> j <| "stargazers_count"
            <*> j <| "watchers_count"
            <*> j <| "open_issues_count"
            <*> j <| "size"
            <*> j <| "default_branch"
            <*> (j <| "pushed_at" >>- toNSDate)
            <*> (j <| "created_at" >>- toNSDate)
            <*> (j <| "updated_at" >>- toNSDate)
    }
}
