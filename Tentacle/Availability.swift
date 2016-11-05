//
//  Availability.swift
//  Tentacle
//
//  Created by Syo Ikeda on 11/6/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

extension DateFormatter {
    @available(*, unavailable, renamed: "iso8601")
    @nonobjc public static var ISO8601: DateFormatter { fatalError() }
}

extension Release.Asset {
    @available(*, unavailable, renamed: "apiURL")
    public var APIURL: URL { fatalError() }
}
