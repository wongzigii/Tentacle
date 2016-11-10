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
            url: URL(string: "https://github.com/Palleas-opensource")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!,
            type: .user
        )

        let palleas = User(
            ID: "48797",
            login: "Palleas",
            url: URL(string: "https://github.com/Palleas")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/48797?v=3")!,
            type: .user
        )

        let expected: [Comment] = [
            Comment(
                ID: "235455442",
                url: URL(string: "https://github.com/Palleas-opensource/Sample-repository/issues/1#issuecomment-235455442")!,
                createdAt: DateFormatter.iso8601.date(from: "2016-07-27T01:28:21Z")!,
                updatedAt: DateFormatter.iso8601.date(from: "2016-07-27T01:28:21Z")!,
                body: "I know right?!",
                author: palleas
            ),
            Comment(
                ID: "235455603",
                url: URL(string: "https://github.com/Palleas-opensource/Sample-repository/issues/1#issuecomment-235455603")!,
                createdAt: DateFormatter.iso8601.date(from: "2016-07-27T01:29:31Z")!,
                updatedAt: DateFormatter.iso8601.date(from: "2016-07-27T01:29:31Z")!,
                body: "👍 Good idea to say stuff like that on internet!",
                author: palleasOpensource
            )
        ]

        let comments: [Comment]? = Fixture.CommentsOnIssue.CommentsOnIssueInSampleRepository.decode()

        XCTAssertEqual(comments!, expected)
    }
}
