//
//  Milestone.swift
//  Tentacle
//
//  Created by Romain Pouclet on 2016-05-23.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

public struct Milestone: Hashable, CustomStringConvertible {
    public enum State {
        case Open
        case Closed
    }

    public let URL: NSURL
    public let htmlURL: NSURL
    public let labelsURL: NSURL
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