//
//  Owner.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-08-02.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct Owner: Hashable, CustomStringConvertible {
    public enum OwnerType: String {
        case User = "User"
        case Organization = "Organization"
    }

    let id: String
    let login: String
    let avatarURL: NSURL
    let gravatarID: String?
    let URL: NSURL
    let type: OwnerType

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

extension Owner: ResourceType {
    public static func decode(j: JSON) -> Decoded<Owner> {
        let f = curry(Owner.init)

        return f
            <^> (j <| "id" >>- toString)
            <*> j <| "login"
            <*> (j <| "avatar_url" >>- toNSURL)
            <*> j <|? "gravatar_id"
            <*> (j <| "html_url" >>- toNSURL)
            <*> (j <| "type" >>- toOwnerType)
    }
}