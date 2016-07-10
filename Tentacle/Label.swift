//
//  Label.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry

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

extension Label: ResourceType {
    public static func decode(json: JSON) -> Decoded<Label> {
        let f = curry(Label.init)
        return f
            <^> (json <| "url" >>- toNSURL)
            <*> json <| "name"
            <*> json <| "color"
    }
}