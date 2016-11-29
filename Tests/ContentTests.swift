//
//  ContentTests.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-11-28.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import XCTest
import Argo
@testable import Tentacle

class ContentTests: XCTestCase {

    func testDecodedContent() {
        let expected = Content(
            type: .file,
            target: nil,
            size: 19,
            name: "README.md",
            path: "README.md",
            sha: "28ec72028c4ae47de689964a23ebb223f10cfe80",
            url: URL(string: "https://github.com/Palleas-opensource/Sample-repository/blob/master/README.md")!,
            downloadURL: URL(string: "https://raw.githubusercontent.com/Palleas-opensource/Sample-repository/master/README.md")
        )

        XCTAssertEqual(Fixture.FileForRepository.ReadMeForSampleRepository.decode()!, expected)
    }
}
