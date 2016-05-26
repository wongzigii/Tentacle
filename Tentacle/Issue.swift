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
//    public let url: NSURL?

//	public let repositoryUrl: NSURL?
//	public let labelsUrl: NSURL?
//	public let commentsUrl: NSURL?
//	public let eventsUrl: NSURL?
//	public let htmlUrl: NSURL?

	public let number: Int
	public let state: State
	public let title: String
	public let body: String
//	public let user: User?
//	public let labels: [Label]
//	public let assignee: User?
//	public let milestone: Milestone?

//	public let locked: Bool?
//	public let comments: Int?
//  public let pullRequest: PullRequest?
//	public let closedAt: NSDate?
//	public let createdAt: NSDate?
//	public let updatedAt: NSDate?

    public var hashValue: Int {
        return id.hashValue
    }

    public var description: String {
        return title
    }

    public init(id: Int, number: Int, state: State, title: String, body: String) {
        self.id = id
        self.number = number
        self.state = state
        self.title = title
        self.body = body
    }

}

public func ==(lhs: Issue, rhs: Issue) -> Bool {
    return lhs.id == rhs.id
        && lhs.number == rhs.number
        && lhs.state == rhs.state
        && lhs.title == rhs.title
        && lhs.body == rhs.body
}

extension Issue: ResourceType {
    public static func decode(j: JSON) -> Decoded<Issue> {
        let f = curry(Issue.init)
        return f
            <^> j <| "id"
//            <*> (j <| "url" >>- toNSURL)
//            <*> (j <| "repository_url" >>- toNSURL)
//			<*> (j <| "labels_url" >>- toNSURL)
//			<*> (j <| "comments_url" >>- toNSURL)
//			<*> (j <| "events_url" >>- toNSURL)
//			<*> (j <| "html_url" >>- toNSURL)
			<*> j <| "number"
			<*> (j <| "state" >>- toIssueState)
			<*> j <| "title"
			<*> j <| "body"
//			<*> j <| "user"
//			<*> j <|| "labels"
//			<*> j <| "assignee"
//			<*> j <| "milestone"
//			<*> j <| "locked"
//			<*> j <| "comments"
//			<*> (j <| "closed_at" >>- toNSDate)
//			<*> (j <| "created_at" >>- toNSDate)
//			<*> (j <| "updated_at" >>- toNSDate)
    }
}
