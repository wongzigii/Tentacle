//
//  RepositoryInfoTests.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-08-02.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
@testable import Tentacle
import Argo

class RepositoryInfoTests: XCTestCase {

    func testUserRepositoryInfoAreEquals() {
        let palleasOpensource = Owner(
            id: "15802020",
            login: "Palleas-opensource",
            avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!,
            gravatarID: "", 
            URL: NSURL(string: "https://github.com/Palleas-opensource")!,
            type: .User
        )

        let expected = [
            RepositoryInfo(
                id: "59615946",
                owner: palleasOpensource,
                name: "Sample-repository",
                fullName: "Palleas-opensource/Sample-repository",
                body: "",
                URL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository")!,
                homepage: nil,
                isPrivate: false,
                isFork: false,
                forksCount: 0,
                stargazersCount: 0,
                watchersCount: 0,
                openIssuesCount: 2,
                size: 2,
                defaultBranch: "master",
                pushedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-14T01:40:08Z")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:17Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:17Z")!
            )
        ]

        let decoded: [RepositoryInfo] = Fixture.RepositoriesForUser.RepositoriesForPalleasOpensource.decode()!

        XCTAssertEqual(decoded, expected)
    }

    func testOrganizationRepositoryAreEqual() {
        let raccommunity = Owner(
            id: "18710012",
            login: "RACCommunity",
            avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/18710012?v=3")!,
            gravatarID: nil,
            URL: NSURL(string: "https://github.com/RACCommunity")!,
            type: .Organization
        )

        let expected = [
            RepositoryInfo(
                id: "35350514",
                owner: raccommunity,
                name: "Rex",
                fullName: "RACCommunity/Rex",
                body: "ReactiveCocoa Extensions",
                URL: NSURL(string: "https://github.com/RACCommunity")!,
                homepage: nil,
                isPrivate: false,
                isFork: false,
                forksCount: 33,
                stargazersCount: 193,
                watchersCount: 193,
                openIssuesCount: 16,
                size: 556,
                defaultBranch: "master",
                pushedAt: NSDateFormatter.ISO8601.dateFromString("2016-08-01T08:15:31Z")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2015-05-10T00:15:08Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-31T12:12:36Z")!
            ),
            RepositoryInfo(
                id: "49464897",
                owner: raccommunity,
                name: "RACNest",
                fullName: "RACCommunity/RACNest",
                body: "RAC + MVVM examples :mouse::mouse::mouse:",
                URL: NSURL(string: "https://github.com/RACCommunity/RACNest")!,
                homepage: nil,
                isPrivate: false,
                isFork: false,
                forksCount: 6,
                stargazersCount: 82,
                watchersCount: 82,
                openIssuesCount: 3,
                size: 1391,
                defaultBranch: "master",
                pushedAt: NSDateFormatter.ISO8601.dateFromString("2016-04-27T07:22:45Z")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-01-12T01:00:02Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-08-02T16:07:39Z")!
            ),
            RepositoryInfo(
                id: "57858100",
                owner: raccommunity,
                name: "contributors",
                fullName: "RACCommunity/contributors",
                body: "ReactiveCocoa's Community Guidelines",
                URL: NSURL(string: "https://github.com/RACCommunity")!,
                homepage: nil,
                isPrivate: false,
                isFork: false,
                forksCount: 1,
                stargazersCount: 16,
                watchersCount: 16,
                openIssuesCount: 4,
                size: 8,
                defaultBranch: "master",
                pushedAt: NSDateFormatter.ISO8601.dateFromString("2016-05-02T10:35:31Z")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-02T00:27:44Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T11:39:23Z")!
            ),
            RepositoryInfo(
                id: "59124784",
                owner: raccommunity,
                name: "racurated",
                fullName: "RACCommunity/racurated",
                body: "Curated list of ReactiveCocoa projects.",
                URL: NSURL(string: "https://github.com/RACCommunity/racurated")!,
                homepage: NSURL(string: "https://raccommunity.github.io/racurated/")!,
                isPrivate: false,
                isFork: false,
                forksCount: 0,
                stargazersCount: 5,
                watchersCount: 5,
                openIssuesCount: 0,
                size: 39,
                defaultBranch: "gh-pages",
                pushedAt: NSDateFormatter.ISO8601.dateFromString("2016-06-07T23:47:44Z")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-18T14:47:59Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T11:39:11Z")!
            )
        ]

        let decoded: [RepositoryInfo] = Fixture.RepositoriesForOrganization.RepositoriesForRACCommunity.decode()!

        XCTAssertEqual(decoded, expected)
    }

}
