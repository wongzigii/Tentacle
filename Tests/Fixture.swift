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

protocol FixtureType {
    var server: Server { get }
    var endpoint: Client.Endpoint { get }
    var page: UInt? { get }
    var pageSize: UInt? { get }
}

extension FixtureType {
    /// The filename used for the local fixture, without an extension
    private func filenameWithExtension(ext: String) -> NSString {
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)!
        
        let path = (components.path! as NSString)
            .pathComponents
            .dropFirst()
            .joinWithSeparator("-")
        
        let query = components.queryItems!
            .map { item in
                if let value = item.value {
                    return "\(item.name)-\(value)"
                } else {
                    return item.name
                }
            }
            .joinWithSeparator("-")
        
        if query == "" {
            return "\(path).\(ext)"
        }
        return "\(path).\(query).\(ext)"
    }
    
    /// The filename used for the local fixture's data.
    var dataFilename: NSString {
        return filenameWithExtension(Fixture.DataExtension)
    }
    
    /// The filename used for the local fixture's HTTP response.
    var responseFilename: NSString {
        return filenameWithExtension(Fixture.ResponseExtension)
    }
    
    /// The URL of the fixture on the API.
    var URL: NSURL {
        return NSURLRequest.create(self.server, self.endpoint, nil, page: page, pageSize: pageSize).URL!
    }
    
    private func fileURLWithExtension(ext: String) -> NSURL {
        let bundle = NSBundle(forClass: ImportedWithFixture.self)
        let filename = filenameWithExtension(ext)
        return bundle.URLForResource(filename.stringByDeletingPathExtension, withExtension: filename.pathExtension)!
    }
    
    /// The URL of the fixture's data within the test bundle.
    var dataFileURL: NSURL {
        return fileURLWithExtension(Fixture.DataExtension)
    }
    
    /// The URL of the fixture's HTTP response within the test bundle.
    var responseFileURL: NSURL {
        return fileURLWithExtension(Fixture.ResponseExtension)
    }
    
    /// The data from the endpoint.
    var data: NSData {
       return NSData(contentsOfURL: dataFileURL)!
    }
    
    /// The HTTP response from the endpoint.
    var response: NSHTTPURLResponse {
        let data = NSData(contentsOfURL: responseFileURL)!
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSHTTPURLResponse
    }
    
    /// The JSON from the Endpoint.
    var JSON: AnyObject {
        return try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    }
    
    /// Decode the fixture's JSON as an object of the returned type.
    func decode<Object: Decodable where Object.DecodedType == Object>() -> Object? {
        return Argo.decode(JSON).value
    }
    
    /// Decode the fixture's JSON as an array of objects of the returned type.
    func decode<Object: Decodable where Object.DecodedType == Object>() -> [Object]? {
        return Argo.decode(JSON).value
    }
}

struct Fixture {
    private static let DataExtension = "data"
    private static let ResponseExtension = "response"
    
    static var allFixtures: [FixtureType] = [
        Release.Carthage0_15,
        Release.Nonexistent,
        Release.TagOnly,
        Releases.Carthage[0],
        Releases.Carthage[1],
    ]
    
    /// Returns the fixture for the given URL, or nil if no such fixture exists.
    static func fixtureForURL(URL: NSURL) -> FixtureType? {
        if let index = allFixtures.indexOf({ $0.URL == URL }) {
            return allFixtures[index]
        }
        return nil
    }
    
    struct Release: FixtureType {
        static let Carthage0_15 = Release(.DotCom, owner: "Carthage", name: "Carthage", tag: "0.15")
        static let Nonexistent = Release(.DotCom, owner: "mdiep", name: "NonExistent", tag: "tag")
        static let TagOnly = Release(.DotCom, owner: "torvalds", name: "linux", tag: "v4.4")
        
        let server: Server
        let repository: Repository
        let tag: String
        let page: UInt? = nil
        let pageSize: UInt? = nil
        
        var endpoint: Client.Endpoint {
            return .ReleaseByTagName(owner: repository.owner, repository: repository.name, tag: tag)
        }
        
        init(_ server: Server, owner: String, name: String, tag: String) {
            self.server = server
            repository = Repository(owner: owner, name: name)
            self.tag = tag
        }
    }
    
    struct Releases: FixtureType {
        static let Carthage = [
            Releases(.DotCom, "Carthage", "Carthage", 1, 30),
            Releases(.DotCom, "Carthage", "Carthage", 2, 30),
        ]
        
        let server: Server
        let repository: Repository
        let page: UInt?
        let pageSize: UInt?
        
        var endpoint: Client.Endpoint {
            return .ReleasesInRepository(owner: repository.owner, repository: repository.name)
        }
        
        init(_ server: Server, _ owner: String, _ name: String, _ page: UInt, _ pageSize: UInt) {
            self.server = server
            repository = Repository(owner: owner, name: name)
            self.page = page
            self.pageSize = pageSize
        }
    }
}
