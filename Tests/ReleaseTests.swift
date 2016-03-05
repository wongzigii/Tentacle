//
//  ReleaseTests.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
@testable import Tentacle
import XCTest

class ReleaseTests: XCTestCase {
    func testDecode() {
        let expected = Release(
            ID: "2698201",
            tag: "0.15",
            URL: NSURL(string: "https://github.com/Carthage/Carthage/releases/tag/0.15")!,
            name: "0.15: YOLOL",
            assets: [
                Release.Asset(
                    ID: "1358331",
                    name: "Carthage.pkg",
                    contentType: "application/octet-stream",
                    URL: NSURL(string: "https://github.com/Carthage/Carthage/releases/download/0.15/Carthage.pkg")!
                ),
                Release.Asset(
                    ID: "1358332",
                    name: "CarthageKit.framework.zip",
                    contentType: "application/zip",
                    URL: NSURL(string: "https://github.com/Carthage/Carthage/releases/download/0.15/CarthageKit.framework.zip")!
                )
            ]
        )
        XCTAssertEqual(Fixture.Release.Carthage0_15.decode(), expected)
    }
}
