//
//  ClientTests.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/5/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import OHHTTPStubs
import ReactiveCocoa
import Result
import Tentacle
import XCTest

public func == <T: Equatable, Error: Equatable> (left: Result<[T], Error>, right: Result<[T], Error>) -> Bool {
    if let left = left.value, right = right.value {
        return left == right
    } else if let left = left.error, right = right.error {
        return left == right
    }
    return false
}

public func == <T: Equatable, Error: Equatable> (left: Result<[[T]], Error>, right: Result<[[T]], Error>) -> Bool {
    if let left = left.value, right = right.value {
        guard left.count == right.count else { return false }
        for idx in left.indices {
            if left[idx] != right[idx] {
                return false
            }
        }
        return true
    } else if let left = left.error, right = right.error {
        return left == right
    }
    return false
}

func ExpectResult
    <O: ResourceType where O.DecodedType == O>
    (producer: SignalProducer<(Response, O), Client.Error>, _ result: Result<[O], Client.Error>, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    let actual = producer.map { $1 }.collect().single()!
    let message: String
    switch result {
    case let .Success(value):
        message = "\(actual) is not equal to \(value)"
    case let .Failure(error):
        message = "\(actual) is not equal to \(error)"
    }
    XCTAssertTrue(actual == result, message, file: file, line: line)
}

func ExpectResult
    <F: EndpointFixtureType, O: ResourceType where O.DecodedType == O>
    (producer: SignalProducer<(Response, O), Client.Error>, _ result: Result<[F], Client.Error>, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    let expected = result.map { fixtures -> [O] in fixtures.map { $0.decode()! } }
    ExpectResult(producer, expected, file: file, line: line)
}

func ExpectResult
    <O: ResourceType where O.DecodedType == O>
    (producer: SignalProducer<(Response, [O]), Client.Error>, _ result: Result<[[O]], Client.Error>, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    let actual = producer.map { $1 }.collect().single()!
    let message: String
    switch result {
    case let .Success(value):
        message = "\(actual) is not equal to \(value)"
    case let .Failure(error):
        message = "\(actual) is not equal to \(error)"
    }
    XCTAssertTrue(actual == result, message, file: file, line: line)
}

func ExpectResult
    <F: EndpointFixtureType, O: ResourceType, C: CollectionType where O.DecodedType == O, C.Generator.Element == F>
    (producer: SignalProducer<(Response, [O]), Client.Error>, _ result: Result<C, Client.Error>, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    let expected = result.map { fixtures -> [[O]] in fixtures.map { $0.decode()! } }
    ExpectResult(producer, expected, file: file, line: line)
}

func ExpectError
    <O: ResourceType where O.DecodedType == O>
    (producer: SignalProducer<(Response, O), Client.Error>, _ error: Client.Error, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    ExpectResult(producer, Result<[O], Client.Error>.Failure(error), file: file, line: line)
}

func ExpectFixtures
    <F: EndpointFixtureType, O: ResourceType where O.DecodedType == O>
    (producer: SignalProducer<(Response, O), Client.Error>, _ fixtures: F..., file: StaticString = __FILE__, line: UInt = __LINE__)
{
    ExpectResult(producer, Result<[F], Client.Error>.Success(fixtures), file: file, line: line)
}

func ExpectFixtures
    <F: EndpointFixtureType, O: ResourceType, C: CollectionType where O.DecodedType == O, C.Generator.Element == F>
    (producer: SignalProducer<(Response, [O]), Client.Error>, _ fixtures: C, file: StaticString = __FILE__, line: UInt = __LINE__)
{
    ExpectResult(producer, .Success(fixtures), file: file, line: line)
}


class ClientTests: XCTestCase {
    private let client = Client(.DotCom)
    
    override func setUp() {
        OHHTTPStubs
            .stubRequestsPassingTest({ request in
                return true
            }, withStubResponse: { request -> OHHTTPStubsResponse in
                let fixture = Fixture.fixtureForURL(request.URL!)!
                let response = fixture.response
                return OHHTTPStubsResponse(fileURL: fixture.dataFileURL, statusCode: Int32(response.statusCode), headers: response.allHeaderFields)
            })
    }
    
    func testReleasesInRepository() {
        let fixtures = Fixture.Releases.Carthage
        ExpectFixtures(
            client.releasesInRepository(fixtures[0].repository),
            fixtures
        )
    }
    
    func testReleasesInRepositoryPage2() {
        let fixtures = Fixture.Releases.Carthage
        ExpectFixtures(
            client.releasesInRepository(fixtures[0].repository, page: 2),
            fixtures.dropFirst()
        )
    }
    
    func testReleaseForTagInRepository() {
        let fixture = Fixture.Release.Carthage0_15
        ExpectFixtures(
            client.releaseForTag(fixture.tag, inRepository: fixture.repository),
            fixture
        )
    }
    
    func testReleaseForTagInRepositoryNonExistent() {
        let fixture = Fixture.Release.Nonexistent
        ExpectError(
            client.releaseForTag(fixture.tag, inRepository: fixture.repository),
            .DoesNotExist
        )
    }
    
    func testReleaseForTagInRepositoryTagOnly() {
        let fixture = Fixture.Release.TagOnly
        ExpectError(
            client.releaseForTag(fixture.tag, inRepository: fixture.repository),
            .DoesNotExist
        )
    }
    
    func testDownloadAsset() {
        let release: Release = Fixture.Release.MDPSplitView1_0_2.decode()!
        let asset = release.assets
            .filter { $0.name == "MDPSplitView.framework.zip" }
            .first!
        
        let result = client
            .downloadAsset(asset)
            .map { URL in
                return NSData(contentsOfURL: URL)!
            }
            .single()!
        XCTAssertEqual(result.value, Fixture.Release.Asset.MDPSplitView_framework_zip.data)
    }
}
