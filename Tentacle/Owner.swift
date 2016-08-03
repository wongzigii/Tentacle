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

    /// The id of the owner
    let id: String

    /// The login of the owner
    let login: String

    /// The url to the owner's avatar
    let avatarURL: NSURL

    /// The id of an owner's gravatar
    let gravatarID: String?

    /// The URL to view this owner in a browser
    let URL: NSURL

    /// The type of owner, either an user of an organization
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