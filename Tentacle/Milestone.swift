//
//  Milestone.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
import Argo
import Curry

public struct Milestone: Hashable, CustomStringConvertible {
    public enum State: String {
        case Open = "open"
        case Closed = "closed"
    }

    public let ID: Int
    public let number: Int
    public let state: State
    public let title: String
    public let contentDescription: String // TODO Change name ?
    public let creator: User
    public let openIssues: Int
    public let closedIssues: Int
    public let createdAt: NSDate
    public let updatedAt: NSDate
    public let closedAt: NSDate?
    public let dueOn: NSDate
    public let URL: NSURL
    public let htmlURL: NSURL
    public let labelsURL: NSURL

    public var hashValue: Int {
        return ID.hashValue
    }

    public var description: String {
        return title
    }

}

public func ==(lhs: Milestone, rhs: Milestone) -> Bool {
    return lhs.ID == rhs.ID
}

internal func toMilestoneState(string: String) -> Decoded<Milestone.State> {
    if let state = Milestone.State(rawValue: string) {
        return .Success(state)
    } else {
        return .Failure(.Custom("Milestone state is invalid"))
    }
}

extension Milestone: ResourceType {
    public static func decode(j: JSON) -> Decoded<Milestone> {
        let closed_at: Decoded<NSDate?> = (j <|? "closed_at").flatMap(toOptionalNSDate)

        return curry(self.init)
            <^> j <| "id"
            <*> j <| "number"
            <*> (j <| "state" >>- toMilestoneState)
            <*> j <| "title"
            <*> j <| "description"
            <*> j <| "creator"
            <*> j <| "open_issues"
            <*> j <| "closed_issues"
            <*> (j <| "created_at" >>- toNSDate)
            <*> (j <| "updated_at" >>- toNSDate)
            <*> closed_at
            <*> (j <| "dueOn" >>- toNSDate)
            <*> (j <| "url" >>- toNSURL)
            <*> (j <| "html_url" >>- toNSURL)
            <*> (j <| "labels_url" >>- toNSURL)

    }
}