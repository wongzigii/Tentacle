//
//  Response.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/10/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation

/// A response from the GitHub API.
public struct Response: Hashable {
    /// The number of requests remaining in the current rate limit window.
    public let rateLimitRemaining: UInt
    
    /// The time at which the current rate limit window resets
    public let rateLimitReset: NSDate
    
    public init(rateLimitRemaining: UInt, rateLimitReset: NSDate) {
        self.rateLimitRemaining = rateLimitRemaining
        self.rateLimitReset = rateLimitReset
    }
    
    /// Initialize a response with HTTP header fields.
    internal init(headerFields: [String : String]) {
        self.rateLimitRemaining = UInt(headerFields["X-RateLimit-Remaining"]!)!
        self.rateLimitReset = NSDate(timeIntervalSince1970: NSTimeInterval(headerFields["X-RateLimit-Reset"]!)!)
    }
    
    public var hashValue: Int {
        return rateLimitRemaining.hashValue ^ rateLimitReset.hashValue
    }
}

public func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.rateLimitRemaining == rhs.rateLimitRemaining
        && lhs.rateLimitReset == rhs.rateLimitReset
}
