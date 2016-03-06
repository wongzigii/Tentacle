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
                let response = fixture.response
                return OHHTTPStubsResponse(fileURL: fixture.dataFileURL, statusCode: Int32(response.statusCode), headers: response.allHeaderFields)
            })
    }
    
    func testReleaseForTagInRepository() {
        let fixture = Fixture.Release.Carthage0_15
        let values = client
            .releaseForTag(fixture.tag, inRepository: fixture.repository)
            .collect()
            .single()?
            .value
        XCTAssertEqual(values!, [fixture.decode()!])
    }
}
