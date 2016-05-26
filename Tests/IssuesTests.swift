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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let palleasOpensource = User(ID: "15802020",
                                     login: "Palleas-opensource",
                                     URL: NSURL(string: "https://api.github.com/users/Palleas-opensource")!,
                                     avatarURL: NSURL(string: "https://avatars.githubusercontent.com/u/15802020?v=3")!,
                                     name: nil,
                                     email: nil,
                                     websiteURL: nil,
                                     company: nil,
                                     joinedDate: NSDate.distantPast())

        let expected = [
            Issue(id: 156633109,
                url: NSURL(string: "https://api.github.com/repos/Palleas-opensource/Sample-repository/issues/1")!,
                number: 1,
                state: .Open,
                title: "This issue is open",
                body: "Issues are pretty cool.",
//                user: palleasOpensource,
//                labels: [],
//                assignee: nil,
//                milestone: nil,
                locked: false,
                comments: 0,
//                pullRequest: nil,
//                closedAt: nil,
                createdAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:39Z")!,
                updatedAt: NSDateFormatter.ISO8601.dateFromString("2016-05-24T23:38:39Z")!
            )
        ]

        let issues: [Issue]? = Fixture.IssuesInRepository.PalleasOpensource.decode()

        XCTAssertEqual(issues!, expected)
    }
}
