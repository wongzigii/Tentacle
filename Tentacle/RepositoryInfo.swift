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
    let id: String
    
    /// The basic informations about the owner of the repository, either an User or an Organization
    let owner: Owner

    /// The name of the repository
    let name: String

    /// The name of the repository prefixed with the name of the owner
    let fullName: String

    /// The description of the repository
    let body: String

    /// The URL of the repository to load in a browser
    let URL: NSURL

    /// The homepage of the reposutiry
    let homepage: NSURL?

    /// Contains true if the repository is private
    let isPrivate: Bool

    /// Contains true if the repository is a fork
    let isFork: Bool

    /// The number of forks of this repository
    let forksCount: Int

    /// The number of users who starred this repository
    let stargazersCount: Int

    /// The number of users watching this repository
    let watchersCount: Int

    /// The number of open issues in this repository
    let openIssuesCount: Int

    /// The date the last push happened at
    let pushedAt: NSDate

    /// The date the repository was created at
    let createdAt: NSDate

    /// The date the repository was last updated
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
            <*> (j <| "pushed_at" >>- toNSDate)
            <*> (j <| "created_at" >>- toNSDate)
            <*> (j <| "updated_at" >>- toNSDate)
    }
}
