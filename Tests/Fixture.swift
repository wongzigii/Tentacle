//
//  Fixtures.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Foundation
@testable import Tentacle

/// A dummy class, so we can ask for the current bundle in Fixture.URL
private class ImportedWithFixture { }

struct Fixture {
    static var allFixtures: [Fixture] = [
        Release.Carthage0_15,
        Release.Nonexistent,
    ]
    
    /// Returns the fixture for the given URL, or nil if no such fixture exists.
    static func fixtureForURL(URL: NSURL) -> Fixture? {
        if let index = allFixtures.indexOf({ $0.URL == URL }) {
            return allFixtures[index]
        }
        return nil
    }
    
    struct Release {
        static var Carthage0_15 = Fixture(.DotCom, .ReleaseByTagName(owner: "Carthage", repository: "Carthage", tag: "0.15"))
        static var Nonexistent = Fixture(.DotCom, .ReleaseByTagName(owner: "mdiep", repository: "NonExistent", tag: "tag"))
    }
    
    init(_ server: Server, _ endpoint: Client.Endpoint) {
        self.server = server
        self.endpoint = endpoint
    }
    
    /// The server that the fixture came from.
    let server: Server
    
    /// The Endpoint that the fixture came from.
    let endpoint: Client.Endpoint
    
    /// The filename used for the local fixture's data.
    var dataFilename: NSString {
        let path: NSString = self.endpoint.path
        let filename: NSString = path
            .pathComponents
            .dropFirst()
            .joinWithSeparator("-")
        return filename.stringByAppendingPathExtension("json")!
    }
    
    /// The URL of the fixture on the API.
    var URL: NSURL {
        return NSURLRequest.create(self.server, self.endpoint, nil).URL!
    }
    
    /// The URL of the fixture's data within the test bundle.
    var dataFileURL: NSURL {
        let bundle = NSBundle(forClass: ImportedWithFixture.self)
        return bundle.URLForResource(dataFilename.stringByDeletingPathExtension, withExtension: dataFilename.pathExtension)!
    }
    
    /// The data from the endpoint.
    var data: NSData {
       return NSData(contentsOfURL: dataFileURL)!
    }
    
    /// The JSON from the Endpoint.
    var JSON: NSDictionary {
        return try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
    }
    
    /// Decode the fixture's JSON as an object of the returned type.
    func decode<Object: Decodable where Object.DecodedType == Object>() -> Object? {
        return Argo.decode(JSON).value
    }
}
