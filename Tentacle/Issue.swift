//
//  Issue.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

/// An Issue on Github
public struct Issue: Hashable, CustomStringConvertible {
	public enum State {
		case Open
        case Closed
	}
	
    public let id: Int
    public let url: NSURL

	public let repositoryUrl: NSURL
	public let labelsUrl: NSURL
	public let commentsUrl: NSURL
	public let eventsUrl: NSURL
	public let htmlUrl: NSURL

	public let number: Int
	public let state: State
	public let title: String
	public let body: String
	public let user: User
	public let labels: [Label]
	public let assignee: User?
	public let milestone: Milestone?

	public let locked: Bool
	public let comments: Int
    public let pullRequest: PullRequest?
	public let closedAt: NSDate?
	public let createdAt: NSDate
	public let updatedAt: NSDate

    public var hashValue: Int {
        return id.hashValue
    }

    public var description: String {
        return title
    }

}

public func ==(lhs: Issue, rhs: Issue) -> Bool {
    return lhs.id == rhs.id
}