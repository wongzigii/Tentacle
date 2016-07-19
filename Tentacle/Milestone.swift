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

    /// The ID of the milestone
    public let ID: String

    /// The number of the milestone in the repository it belongs to
    public let number: Int

    /// The state of the Milestone, open or closed
    public let state: State

    /// The title of the milestone
    public let title: String

    /// The description of the milestone
    public let body: String

    /// The user who created the milestone
    public let creator: User

    /// The number of the open issues in the milestone
    public let numberOfOpenIssues: Int

    /// The number of closed issues in the milestone
    public let numberOfClosedIssues: Int

    /// The date the milestone was created
    public let createdAt: NSDate

    /// The date the milestone was last updated at
    public let updatedAt: NSDate

    /// The date the milestone was closed at, if ever
    public let closedAt: NSDate?

    /// The date the milestone is due on
    public let dueOn: NSDate

    /// The URL to view this milestone in a browser
    public let URL: NSURL

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
            <^> (j <| "id" >>- toString)
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
            <*> (j <| "due_on" >>- toNSDate)
            <*> (j <| "html_url" >>- toNSURL)
    }
}