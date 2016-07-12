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
        let palleasOpensource = User(ID: "15802020",
                                     login: "Palleas-opensource",
                                     URL: NSURL(string: "https://api.github.com/users/Palleas-opensource")!,
                                     avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!)

        let expected = [
            Issue(id: 156633109,
                url: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/issues/1")!,
                number: 1,
                state: .Open,
                title: "This issue is open",
                body: "Issues are pretty cool.",
                user: palleasOpensource,
                labels: [Label(URL: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/labels/bug")!, name: "bug", color: "ee0701"),
                    Label(URL: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/labels/duplicate")!, name: "duplicate", color: "cccccc"),
                    Label(URL: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/labels/enhancement")!, name: "enhancement", color: "84b6eb")],
//                assignee: nil,
//                milestone: nil,
                locked: false,
                comments: 0,
//                pullRequest: nil,
                closedAt: nil,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:39Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-07-10T00:50:33Z")!
            )
        ]

        let issues: [Issue]? = Fixture.IssuesInRepository.PalleasOpensource.decode()

        XCTAssertEqual(issues!, expected)
    }
}
