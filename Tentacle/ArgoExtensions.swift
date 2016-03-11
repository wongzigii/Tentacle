//
//  ArgoExtensions.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/10/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Result


extension Decodable {
    internal static func decode(JSON: NSDictionary) -> Result<DecodedType, DecodeError> {
        switch decode(.parse(JSON)) {
        case let .Success(object):
            return .Success(object)
        case let .Failure(error):
            return .Failure(error)
        }
    }
}

extension DecodeError: Hashable {
    public var hashValue: Int {
        switch self {
        case let .TypeMismatch(expected: expected, actual: actual):
            return expected.hashValue ^ actual.hashValue
            
        case let .MissingKey(string):
            return string.hashValue
            
        case let .Custom(string):
            return string.hashValue
        }
    }
}

public func ==(lhs: DecodeError, rhs: DecodeError) -> Bool {
    switch (lhs, rhs) {
    case let (.TypeMismatch(expected: expected1, actual: actual1), .TypeMismatch(expected: expected2, actual: actual2)):
        return expected1 == expected2 && actual1 == actual2
        
    case let (.MissingKey(string1), .MissingKey(string2)):
        return string1 == string2
        
    case let (.Custom(string1), .Custom(string2)):
        return string1 == string2
        
    default:
        return false
    }
}

internal func toString(number: Int) -> Decoded<String> {
    return .Success(number.description)
}
