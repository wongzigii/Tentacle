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
	
    public let id: Int
    public let url: NSURL?

	public let number: Int
	public let state: State
	public let title: String
	public let body: String
//	public let user: User?
	public let labels: [Label]
	public let assignee: User?
//	public let milestone: Milestone?

	public let locked: Bool
	public let comments: Int
//  public let pullRequest: PullRequest?
//	public let closedAt: NSDate?
	public let createdAt: NSDate?
	public let updatedAt: NSDate?

    public var hashValue: Int {
        return id.hashValue
    }

    public var description: String {
        return title
    }

    public init(id: Int, url: NSURL?, number: Int, state: State, title: String, body: String, user: User, labels: [Label], assignee: User?, locked: Bool, comments: Int, closedAt: NSDate?, createdAt: NSDate?, updatedAt: NSDate?) {
        self.id = id
        self.url = url
        self.number = number
        self.state = state
        self.title = title
        self.body = body
        self.locked = locked
        self.comments = comments
        self.labels = labels
        self.assignee = assignee
//        self.closedAt = closedAt
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
//			<*> j <| "milestone"
			<*> j <| "locked"
			<*> j <| "comments"
			<*> closed_at
			<*> (j <| "created_at" >>- toNSDate)
			<*> (j <| "updated_at" >>- toNSDate)
    }
}
