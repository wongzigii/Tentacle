//
//  FoundationExtensions.swift
//  Tentacle
//
//  Created by Matt Diephouse on 4/12/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    @nonobjc public static var ISO8601: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier:"en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = NSTimeZone(abbreviation:"UTC")
        return formatter
    }()
}
