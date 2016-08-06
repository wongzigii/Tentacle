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
    /// The id of the repository
    public let id: String
    
    /// The basic informations about the owner of the repository, either an User or an Organization
    public let owner: User

    /// The name of the repository
    public let name: String

    /// The name of the repository prefixed with the name of the owner
    public let nameWithOwner: String

    /// The description of the repository
    public let body: String?

    /// The URL of the repository to load in a browser
    public let URL: NSURL

    /// The homepage of the repository
    public let homepage: NSURL?

    /// Contains true if the repository is private
    public let isPrivate: Bool

    /// Contains true if the repository is a fork
    public let isFork: Bool

    /// The number of forks of this repository
    public let forksCount: Int

    /// The number of users who starred this repository
    public let stargazersCount: Int

    /// The number of users watching this repository
    public let watchersCount: Int

    /// The number of open issues in this repository
    public let openIssuesCount: Int

    /// The date the last push happened at
    public let pushedAt: NSDate

    /// The date the repository was created at
    public let createdAt: NSDate

    /// The date the repository was last updated
    public let updatedAt: NSDate

    public var hashValue: Int {
        return id.hashValue ^ nameWithOwner.hashValue
    }

    public var description: String {
        return nameWithOwner
    }
}

public func ==(lhs: RepositoryInfo, rhs: RepositoryInfo) -> Bool {
    return lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.nameWithOwner == rhs.nameWithOwner
}

extension RepositoryInfo: ResourceType {
    public static func decode(j: JSON) -> Decoded<RepositoryInfo> {
        let f = curry(RepositoryInfo.init)

        return f
            <^> (j <| "id" >>- toString)
            <*> j <| "owner"
            <*> j <| "name"
            <*> j <| "full_name"
            <*> j <|? "description"
            <*> (j <| "html_url" >>- toNSURL)
            <*> (j <|? "homepage" >>- toOptionalNSURL)
            <*> j <| "private"
            <*> j <| "fork"
            <*> j <| "forks_count"
            <*> j <| "stargazers_count"
            <*> j <| "watchers_count"
            <*> j <| "open_issues_count"
            <*> (j <| "pushed_at" >>- toNSDate)
            <*> (j <| "created_at" >>- toNSDate)
            <*> (j <| "updated_at" >>- toNSDate)
    }
}
