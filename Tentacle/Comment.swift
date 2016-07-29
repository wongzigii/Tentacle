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

    /// The id of the issue
    public let ID: String
    /// The URL to view this comment in a browser
    public let URL: NSURL
    /// The date this comment was created at
    public let createdAt: NSDate
    /// The date this comment was last updated at
    public let updatedAt: NSDate
    /// The body of the comment
    public let body: String
    /// The author of this comment
    public let author: User
    
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
