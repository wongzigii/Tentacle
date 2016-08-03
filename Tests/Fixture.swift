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
    var URL: NSURL { get }
    var contentType: String { get }
}

protocol EndpointFixtureType: FixtureType {
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
        
        let query = components.queryItems?
            .map { item in
                if let value = item.value {
                    return "\(item.name)-\(value)"
                } else {
                    return item.name
                }
            }
            .joinWithSeparator("-")
        
        if let query = query where query != "" {
            return "\(path).\(query).\(ext)"
        }
        return "\(path).\(ext)"
    }
    
    /// The filename used for the local fixture's data.
    var dataFilename: NSString {
        return filenameWithExtension(Fixture.DataExtension)
    }
    
    /// The filename used for the local fixture's HTTP response.
    var responseFilename: NSString {
        return filenameWithExtension(Fixture.ResponseExtension)
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
}

extension EndpointFixtureType {
    /// The URL of the fixture on the API.
    var URL: NSURL {
        return NSURL(self.server, self.endpoint, page: page, pageSize: pageSize)
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
        let decoded: Decoded<[Object]> =  Argo.decode(JSON)
        print("Decoded = \(decoded.error)")
        return decoded.value
    }
}

struct Fixture {
    private static let DataExtension = "data"
    private static let ResponseExtension = "response"
    
    static var allFixtures: [FixtureType] = [
        Release.Carthage0_15,
        Release.MDPSplitView1_0_2,
        Release.Nonexistent,
        Release.TagOnly,
        Release.Asset.MDPSplitView_framework_zip,
        Releases.Carthage[0],
        Releases.Carthage[1],
        UserInfo.mdiep,
        UserInfo.test,
        IssuesInRepository.PalleasOpensource,
        CommentsOnIssue.CommentsOnIssueInSampleRepository,
        RepositoriesForUser.RepositoriesForPalleasOpensource
    ]
    
    /// Returns the fixture for the given URL, or nil if no such fixture exists.
    static func fixtureForURL(URL: NSURL) -> FixtureType? {
        if let index = allFixtures.indexOf({ $0.URL == URL }) {
            return allFixtures[index]
        }
        return nil
    }
    
    struct Release: EndpointFixtureType {
        static let Carthage0_15 = Release(.DotCom, owner: "Carthage", name: "Carthage", tag: "0.15")
        static let MDPSplitView1_0_2 = Release(.DotCom, owner: "mdiep", name: "MDPSplitView", tag: "1.0.2")
        static let Nonexistent = Release(.DotCom, owner: "mdiep", name: "NonExistent", tag: "tag")
        static let TagOnly = Release(.DotCom, owner: "torvalds", name: "linux", tag: "v4.4")
        
        let server: Server
        let repository: Repository
        let tag: String
        let page: UInt? = nil
        let pageSize: UInt? = nil
        let contentType = Client.APIContentType
        
        var endpoint: Client.Endpoint {
            return .ReleaseByTagName(owner: repository.owner, repository: repository.name, tag: tag)
        }
        
        init(_ server: Server, owner: String, name: String, tag: String) {
            self.server = server
            repository = Repository(owner: owner, name: name)
            self.tag = tag
        }
        
        struct Asset: FixtureType {
            static let MDPSplitView_framework_zip = Asset("https://api.github.com/repos/mdiep/MDPSplitView/releases/assets/433845")
            
            let URL: NSURL
            let contentType = Client.DownloadContentType
            
            init(_ URLString: String) {
                URL = NSURL(string: URLString)!
            }
        }
    }
    
    struct Releases: EndpointFixtureType {
        static let Carthage = [
            Releases(.DotCom, "Carthage", "Carthage", 1, 30),
            Releases(.DotCom, "Carthage", "Carthage", 2, 30),
        ]
        
        let server: Server
        let repository: Repository
        let page: UInt?
        let pageSize: UInt?
        let contentType = Client.APIContentType
        
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
    
    struct UserInfo: EndpointFixtureType {
        static let mdiep = UserInfo(.DotCom, "mdiep")
        static let test = UserInfo(.DotCom, "test")
        
        let server: Server
        let login: String
        
        let page: UInt? = nil
        let pageSize: UInt? = nil
        let contentType = Client.APIContentType
        
        var endpoint: Client.Endpoint {
            return .UserInfo(login: login)
        }
        
        init(_ server: Server, _ login: String) {
            self.server = server
            self.login = login
        }
    }

    struct IssuesInRepository: EndpointFixtureType {
        static let PalleasOpensource = IssuesInRepository(.DotCom, "Palleas-opensource", "Sample-repository")

        let server: Server

        var endpoint: Client.Endpoint {
            return .IssuesInRepository(owner: owner, repository: repository)
        }

        let page: UInt? = nil
        let pageSize: UInt? = nil
        let contentType = Client.APIContentType

        let owner: String
        let repository: String

        init(_ server: Server, _ owner: String, _ repository: String) {
            self.server = server
            self.owner = owner
            self.repository = repository
        }
    }

    struct CommentsOnIssue: EndpointFixtureType {
        static let CommentsOnIssueInSampleRepository = CommentsOnIssue(.DotCom, 1, "Palleas-Opensource", "Sample-repository")

        let server: Server
        let page: UInt? = nil
        let pageSize: UInt? = nil

        let number: Int
        let owner: String
        let repository: String

        let contentType = Client.APIContentType

        var endpoint: Client.Endpoint {
            return .CommentsOnIssue(number: number, owner: owner, repository: repository)
        }

        init(_ server: Server, _ number: Int, _ owner: String, _ repository: String) {
            self.server = server
            self.number = number
            self.owner = owner
            self.repository = repository
        }
    }

    struct RepositoriesForUser: EndpointFixtureType {
        static let RepositoriesForPalleasOpensource = RepositoriesForUser(.DotCom, "Palleas-Opensource")
        
        let server: Server
        let page: UInt? = nil
        let pageSize: UInt? = nil

        let owner: String

        let contentType = Client.APIContentType

        var endpoint: Client.Endpoint {
            return .RepositoriesForUser(user: owner)
        }

        init(_ server: Server, _ owner: String) {
            self.server = server
            self.owner = owner
        }
    }
}
