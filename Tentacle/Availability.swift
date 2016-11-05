//
//  Availability.swift
//  Tentacle
//
//  Created by Syo Ikeda on 11/6/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import ReactiveSwift

extension DateFormatter {
    @available(*, unavailable, renamed: "iso8601")
    @nonobjc public static var ISO8601: DateFormatter { fatalError() }
}

extension Release.Asset {
    @available(*, unavailable, renamed: "apiURL")
    public var APIURL: URL { fatalError() }
}

extension Client {
    @available(*, unavailable, renamed: "download(asset:)")
    public func downloadAsset(_ asset: Release.Asset) -> SignalProducer<URL, Error> { fatalError() }

    @available(*, unavailable, renamed: "user(withLogin:)")
    public func userWithLogin(_ login: String) -> SignalProducer<(Response, UserInfo), Error> { fatalError() }

    @available(*, unavailable, renamed: "assignedIssues(page:perPage:)")
    public func assignedIssues(_ page: UInt = 1, perPage: UInt = 30) -> SignalProducer<(Response, [Issue]), Error> { fatalError() }

    @available(*, unavailable, renamed: "issues(in:page:perPage:)")
    public func issuesInRepository(_ repository: Repository, page: UInt = 1, perPage: UInt = 30) -> SignalProducer<(Response, [Issue]), Error> { fatalError() }

    @available(*, unavailable, renamed: "comments(onIssue:in:page:perPage:)")
    public func commentsOnIssue(_ issue: Int, repository: Repository, page: UInt = 1, perPage: UInt = 30) -> SignalProducer<(Response, [Comment]), Error> { fatalError() }
}
