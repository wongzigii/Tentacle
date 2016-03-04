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
let result = SignalProducer(values: Fixtures.endpoints)
    .flatMap(.Concat) { endpoint -> SignalProducer<(), NSError> in
        let request = NSURLRequest.create(.DotCom, endpoint)
        print("*** Downloading \(request.URL!)")
        return session
            .rac_dataWithRequest(request)
            .on(next: { data, response in
                let URL = baseURL.URLByAppendingPathComponent(endpoint.path).URLByAppendingPathExtension("json")
                try! fileManager.createDirectoryAtURL(URL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
                data.writeToURL(URL, atomically: true)
            })
            .map { _, _ in () }
    }
    .wait()

if let error = result.error {
    print("Error updating fixtures: \(error)")
}
