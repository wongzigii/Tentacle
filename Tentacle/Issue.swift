//
//  Issue.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Curry

/// An Issue on Github
public struct Issue: Hashable, CustomStringConvertible {
    public enum State: String {
        case Open = "open"
        case Closed = "closed"
	}

    /// The id of the issue
    public let id: Int

    /// The API URL to fetch this issue
    public let url: NSURL?

    /// The number of the issue in the repository it belongs to
	public let number: Int

    /// The state of the issue, open or closed
	public let state: State

    /// The title of the issue
	public let title: String

    /// The body of the issue
	public let body: String

    /// The author of the issue
	public let user: User?

    /// The labels associated to this issue, if any
	public let labels: [Label]

    /// The user assigned to this issue, if any
	public let assignee: User?

    /// The milestone this issue belongs to, if any
	public let milestone: Milestone?

    /// True if the issue has been closed by a contributor
	public let locked: Bool

    /// The number of comments
	public let comments: Int

    /// Contains the informations like the diff URL when the issue is a pull-request
    public let pullRequest: PullRequest?

    /// The date this issue was closed at, if it ever were
	public let closedAt: NSDate?

    /// The date this issue was created at
	public let createdAt: NSDate

    /// The date this issue was updated at
	public let updatedAt: NSDate

    public var hashValue: Int {
        return id.hashValue
    }

    public var description: String {
        return title
    }

    public init(id: Int, url: NSURL?, number: Int, state: State, title: String, body: String, user: User, labels: [Label], assignee: User?, milestone: Milestone?, locked: Bool, comments: Int, pullRequest: PullRequest?, closedAt: NSDate?, createdAt: NSDate, updatedAt: NSDate) {
        self.id = id
        self.url = url
        self.number = number
        self.state = state
        self.title = title
        self.body = body
        self.user = user
        self.milestone = milestone
        self.locked = locked
        self.comments = comments
        self.pullRequest = pullRequest
        self.labels = labels
        self.assignee = assignee
        self.closedAt = closedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}

public func ==(lhs: Issue, rhs: Issue) -> Bool {
    return lhs.id == rhs.id
        && lhs.url == rhs.url
        && lhs.number == rhs.number
        && lhs.state == rhs.state
        && lhs.title == rhs.title
        && lhs.body == rhs.body
        && lhs.locked == rhs.locked
        && lhs.comments == rhs.comments
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
        && lhs.labels == rhs.labels
        && lhs.milestone == rhs.milestone
        && lhs.pullRequest == rhs.pullRequest
}

extension Issue: ResourceType {
    public static func decode(j: JSON) -> Decoded<Issue> {
        let f = curry(Issue.init)

        let closed_at: Decoded<NSDate?> = (j <|? "closed_at").flatMap(toOptionalNSDate)

        return f
            <^> j <| "id"
            <*> (j <| "url" >>- toNSURL)
			<*> j <| "number"
			<*> (j <| "state" >>- toIssueState)
			<*> j <| "title"
			<*> j <| "body"
			<*> j <| "user"
			<*> j <|| "labels"
			<*> j <|? "assignee"
			<*> j <|? "milestone"
			<*> j <| "locked"
			<*> j <| "comments"
            <*> j <|? "pull_request"
			<*> closed_at
			<*> (j <| "created_at" >>- toNSDate)
			<*> (j <| "updated_at" >>- toNSDate)
    }
}
