//
//  main.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

// A "script" to automatically download the test fixtures needed for Tentacle's unit tests.
// This makes it easy to keep the fixtures up-to-date.

import Foundation
import ReactiveCocoa
import Result
@testable import Tentacle

let baseURL = NSURL(fileURLWithPath: Process.arguments[1])

let fileManager = NSFileManager.defaultManager()
let session = NSURLSession.sharedSession()
let result = SignalProducer(values: Fixture.allFixtures)
    .flatMap(.Concat) { fixture -> SignalProducer<(), NSError> in
        let request = NSURLRequest.create(fixture.server, fixture.endpoint, nil)
        let URL = baseURL.URLByAppendingPathComponent(fixture.filename as String)
        let path = (URL.path! as NSString).stringByAbbreviatingWithTildeInPath
        print("*** Downloading \(request.URL!)\n    to \(path)")
        return session
            .rac_dataWithRequest(request)
            .on(next: { data, response in
                try! fileManager.createDirectoryAtURL(URL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
                data.writeToURL(URL, atomically: true)
            })
            .map { _, _ in () }
    }
    .wait()

if let error = result.error {
    print("Error updating fixtures: \(error)")
}
