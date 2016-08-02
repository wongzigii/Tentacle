//
//  Owner.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-08-02.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public struct Owner: Hashable, CustomStringConvertible {
    enum Type: String {
        case User = "User"
        case Organization = "Org"
    }

    let id: String
    let login: String
    let avatarURL: NSURL
    let gravatarID: String?
    let URL: NSURL
    let type: Type

    public var hashValue: Int {
        return id.hashValue ^ login.hashValue
    }

    public var description: String {
        return login
    }
}

public func ==(lhs: Owner, rhs: Owner) -> Bool {
    return lhs.id == rhs.id
        && lhs.login == rhs.login
}