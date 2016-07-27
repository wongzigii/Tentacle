//
//  CommentsTests.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-07-27.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
@testable import Tentacle
import XCTest

class CommentsTests: XCTestCase {

    func testDecodedCommentsOnSampleRepositoryIssue() {
        let palleasOpensource = User(
            ID: "15802020",
            login: "Palleas-opensource",
            URL: NSURL(string: "https://github.com/Palleas-opensource")!,
            avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!
        )

        let palleas = User(
            ID: "48797",
            login: "Palleas",
            URL: NSURL(string: "https://github.com/Palleas")!,
            avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/48797?v=3")!
        )

        let expected: [Comment] = [
            Comment(
                ID: "235455442",
                URL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/issues/1#issuecomment-235455442")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T01:28:21Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T01:28:21Z")!,
                body: "I know right?!",
                user: palleas
            ),
            Comment(
                ID: "235455603",
                URL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/issues/1#issuecomment-235455603")!,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T01:29:31Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-27T01:29:31Z")!,
                body: "👍 Good idea to say stuff like that on internet!",
                user: palleasOpensource
            )
        ]

        let comments: [Comment]? = Fixture.CommentsOnIssue.CommentsOnIssueInSampleRepository.decode()

        XCTAssertEqual(comments!, expected)
    }
}
