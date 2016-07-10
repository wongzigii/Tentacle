//
//  ArgoExtensions.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/10/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Foundation
import Result


internal func decode<T: Decodable where T == T.DecodedType>(object: AnyObject) -> Result<T, DecodeError> {
    let decoded: Decoded<T> = decode(object)
    switch decoded {
    case let .Success(object):
        return .Success(object)
    case let .Failure(error):
        return .Failure(error)
    }
}

internal func decode<T: Decodable where T == T.DecodedType>(object: AnyObject) -> Result<[T], DecodeError> {
    let decoded: Decoded<[T]> = decode(object)
    switch decoded {
    case let .Success(object):
        return .Success(object)
    case let .Failure(error):
        return .Failure(error)
    }
}

internal func toString(number: Int) -> Decoded<String> {
    return .Success(number.description)
}

internal func toInt(string: String) -> Decoded<Int> {
    if let int = Int(string) {
        return .Success(int)
    } else {
        return .Failure(.Custom("String is not a valid number"))
    }
}

internal func toIssueState(string: String) -> Decoded<Issue.State> {
    if let state = Issue.State(rawValue: string) {
        return .Success(state)
    } else {
        return .Failure(.Custom("String \(string) does not represent a valid issue state"))
    }
}

//internal func toLabel() -> Decoded<Label> {
////    public let URL: NSURL
////    public let name: String
////    public let color: String
//
//    return .Success(Label(URL: NSURL(string: "http://github.com")!, name: "", ""
//}

internal func toNSDate(string: String) -> Decoded<NSDate> {
    if let date = NSDateFormatter.ISO8601.dateFromString(string) {
        return .Success(date)
    } else {
        return .Failure(.Custom("Date is not ISO8601 formatted"))
    }
}

internal func toNSURL(string: String) -> Decoded<NSURL> {
    if let url = NSURL(string: string) {
        return .Success(url)
    } else {
        return .Failure(.Custom("URL is not properly formatted"))
    }
}
