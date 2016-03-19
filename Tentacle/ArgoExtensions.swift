//
//  ArgoExtensions.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/10/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
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
