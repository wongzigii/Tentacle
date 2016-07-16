//
//  IssuesTests.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-24.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
@testable import Tentacle
import XCTest

class IssuesTests: XCTestCase {
    
    func testDecodedPalleasOpensourceIssues() {
        let palleasOpensource = User(
            ID: "15802020",
            login: "Palleas-opensource",
            URL: NSURL(string: "https://api.github.com/users/Palleas-opensource")!,
            avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!
        )

        let shipItMilestone = Milestone(
            ID: "1881390",
            number: 1,
            state: .Open,
            title: "Release this app",
            contentDescription: "That'd be cool",
            creator: palleasOpensource,
            numberOfOpenIssues: 1,
            numberOfClosedIssues: 0,
            createdAt: NSDateFormatter.ISO8601.dateFromString("2016-07-13T16:56:48Z")!,
            updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-13T16:56:57Z")!,
            closedAt: nil,
            dueOn: NSDateFormatter.ISO8601.dateFromString("2016-07-25T04:00:00Z")!,
            URL: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/milestones/1")!
        )

        let updateReadmePullRequest = PullRequest(
            URL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/pull/3")!,
            diffURL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/pull/3.diff")!,
            patchURL: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/pull/3.patch")!
        )

        let expected = [
            Issue(id: 165458041,
                url: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/pull/3"),
                number: 3,
                state: .Open,
                title: "Add informations in Readme",
                body: "![Giphy](http://media2.giphy.com/media/jxhJ8ylaYIPbG/giphy.gif)",
                user: palleasOpensource,
                labels: [],
                assignee: nil,
                milestone: nil,
                locked: false,
                comments: 0,
                pullRequest: updateReadmePullRequest,
                closedAt: nil,
                createdAt:  NSDateFormatter.ISO8601.dateFromString("2016-07-14T01:40:08Z")!,
                updatedAt:  NSDateFormatter.ISO8601.dateFromString("2016-07-14T01:40:08Z")!),
            Issue(id: 156633109,
                url: NSURL(string: "https://github.com/Palleas-opensource/Sample-repository/issues/1")!,
                number: 1,
                state: .Open,
                title: "This issue is open",
                body: "Issues are pretty cool.",
                user: palleasOpensource,
                labels: [
                    Label(
                        name: "bug",
                        color: SWColor(hexString: "ee0701")!
                    ),
                    Label(
                        name: "duplicate",
                        color: SWColor(hexString: "cccccc")!
                    ),
                    Label(
                        name: "enhancement",
                        color: SWColor(hexString: "84b6eb")!
                    )
                ],
                assignee: palleasOpensource,
                milestone: shipItMilestone,
                locked: false,
                comments: 0,
                pullRequest: nil,
                closedAt: nil,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:39Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-13T16:56:57Z")!
            )
        ]

        let issues: [Issue]? = Fixture.IssuesInRepository.PalleasOpensource.decode()

        XCTAssertEqual(issues!, expected)
    }
}
