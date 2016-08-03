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

    func testRepositoryInfoAreEquals() {
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

}
