//
//  Comment.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-07-27.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Curry
import Argo

public struct Comment: Hashable, CustomStringConvertible {

    public let ID: String
    public let URL: NSURL
    public let createdAt: NSDate
    public let updatedAt: NSDate
    public let body: String
    public let user: User
    
    public var hashValue: Int {
        return ID.hashValue
    }

    public var description: String {
        return body
    }
}

public func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.ID == rhs.ID
        && lhs.URL == rhs.URL
        && lhs.body == rhs.body
}

extension Comment: ResourceType {
    public static func decode(j: JSON) -> Decoded<Comment> {
        let f = curry(Comment.init)

        return f
            <^> (j <| "id" >>- toString)
            <*> (j <| "html_url" >>- toNSURL)
            <*> (j <| "created_at" >>- toNSDate)
            <*> (j <| "updated_at" >>- toNSDate)
            <*> j <| "body"
            <*> j <| "user"
    }
}
