//
//  ClientTests.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/5/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import OHHTTPStubs
import Tentacle
import XCTest

class ClientTests: XCTestCase {
    private let client = Client(.DotCom)
    
    override func setUp() {
        OHHTTPStubs
            .stubRequestsPassingTest({ request in
                return Fixture.fixtureForURL(request.URL!) != nil
            }, withStubResponse: { request -> OHHTTPStubsResponse in
                let fixture = Fixture.fixtureForURL(request.URL!)!
                return OHHTTPStubsResponse(fileURL: fixture.dataFileURL, statusCode: 200, headers: nil)
            })
    }
    
    func testReleaseForTagInRepository() {
        let values = client
            .releaseForTag("0.15", inRepository: Repository(owner: "Carthage", name: "Carthage"))
            .collect()
            .single()?
            .value
        XCTAssertEqual(values!, [Fixture.Release.Carthage0_15.decode()!])
    }
}
