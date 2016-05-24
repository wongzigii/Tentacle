//
//  Label.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public struct Label: Hashable, CustomStringConvertible {
    public let URL: NSURL
    public let name: String
    public let color: String

    public var hashValue: Int {
        return name.hashValue
    }

    public var description: String {
        return name
    }
}

public func ==(lhs: Label, rhs: Label) -> Bool {
    return lhs.name == rhs.name
}