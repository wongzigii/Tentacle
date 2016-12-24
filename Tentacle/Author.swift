//
//  Author.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-12-22.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Ogra
import Argo

public struct Author {
    let name: String
    let email: String

    public init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}

extension Author: Encodable {
    public func encode() -> JSON {
        return JSON.object([
            "name": self.name.encode(),
            "email": self.email.encode()
            ])
    }
}

extension Author: Hashable, Equatable {
    public var hashValue: Int {
        return name.hashValue ^ email.hashValue
    }

    static public func ==(lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
            && lhs.email == rhs.email
    }
}
