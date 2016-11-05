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
}
