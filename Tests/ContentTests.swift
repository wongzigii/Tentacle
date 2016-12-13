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

    func testDecodedFile() {
        let expected: Content = .file(Content.File(
            content: .file(size: 19, downloadURL: URL(string: "https://raw.githubusercontent.com/Palleas-opensource/Sample-repository/master/README.md")!),
            name: "README.md",
            path: "README.md",
            sha: "28ec72028c4ae47de689964a23ebb223f10cfe80",
            url: URL(string: "https://github.com/Palleas-opensource/Sample-repository/blob/master/README.md")!
        ))

        XCTAssertEqual(Fixture.FileForRepository.ReadMeForSampleRepository.decode()!, expected)
    }

    func testDecodedDirectory() {
        let expected: Content = .directory([
            Content.File(
                content: .file(size: 1086, downloadURL: URL(string: "https://raw.githubusercontent.com/mdiep/Tentacle/master/update-test-fixtures/Info.plist")!),
                name: "Info.plist",
                path: "update-test-fixtures/Info.plist",
                sha: "3b6fd366cd32ef147c27ad49353b29f1ef5daf1c",
                url: URL(string: "https://github.com/mdiep/Tentacle//master/update-test-fixtures/Info.plist")!
            ),
            Content.File(
                content: .file(size: 2340, downloadURL: URL(string: "https://raw.githubusercontent.com/mdiep/Tentacle/master/update-test-fixtures/main.swift")!),
                name: "main.swift",
                path: "update-test-fixtures/main.swift",
                sha: "e3fe7edcb2247a69c6eade1719d1e0cd83595cf9",
                url: URL(string: "https://github.com/mdiep/Tentacle/blob/master/update-test-fixtures/main.swift")!
            )
        ])

        XCTAssertEqual(Fixture.FileForRepository.DirectoryInTentacle.decode()!, expected)
    }

    func testDecodedSubmodule() {
        let expected: Content = .file(Content.File(
            content: .submodule(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git"),
            name: "ReactiveSwift",
            path: "Carthage/Checkouts/ReactiveSwift",
            sha: "55345ebd4ec28baeacb4041a99d56839428bcaff",
            url: URL(string: "https://github.com/ReactiveCocoa/ReactiveSwift/tree/55345ebd4ec28baeacb4041a99d56839428bcaff")!
        ))

        XCTAssertEqual(Fixture.FileForRepository.SubmoduleInTentacle.decode()!, expected)
    }

    func testDecodedSymlink() {
        let expected: Content = .file(Content.File(
            content: .symlink(target: "/usr/bin/say", downloadURL: URL(string: "https://raw.githubusercontent.com/Palleas-opensource/Sample-repository/master/say")),
            name: "say",
            path: "say",
            sha: "1e3f1fd0bc1f65cf4701c217f4d1fd9a3cd50721",
            url: URL(string: "https://github.com/Palleas-opensource/Sample-repository/blob/master/say")!
        ))

        XCTAssertEqual(Fixture.FileForRepository.SymlinkInSampleRepository.decode()!, expected)
    }
}
