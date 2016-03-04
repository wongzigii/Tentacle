//
//  Fixtures.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
@testable import Tentacle


struct Fixture {
    static var allFixtures: [Fixture] = [
        Release.Carthage0_15,
        Release.Nonexistent,
    ]
    
    struct Release {
        static var Carthage0_15 = Fixture(.ReleaseByTagName(owner: "Carthage", repository: "Carthage", tag: "0.15"))
        static var Nonexistent = Fixture(.ReleaseByTagName(owner: "mdiep", repository: "NonExistent", tag: "tag"))
    }
    
    init(_ endpoint: Client.Endpoint) {
        self.endpoint = endpoint
    }
    
    /// The Endpoint that the fixture came from.
    let endpoint: Client.Endpoint
    
    /// The filename used for the local fixture.
    var filename: NSString {
        let path: NSString = self.endpoint.path
        let filename: NSString = path
            .pathComponents
            .dropFirst()
            .joinWithSeparator("-")
        return filename.stringByAppendingPathExtension("json")!
    }
    
    /// The URL of the fixture within the test bundle.
    var URL: NSURL {
        let bundle = NSBundle(forClass: GitHubErrorTests.self)
        return bundle.URLForResource(filename.stringByDeletingPathExtension, withExtension: filename.pathExtension)!
    }
    
    /// The JSON from the Endpoint.
    lazy var JSON: NSDictionary = {
        let data = NSData(contentsOfURL: self.URL)!
        return try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
    }()
}
