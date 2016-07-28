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
let result = SignalProducer<FixtureType, NSError>(values: Fixture.allFixtures)
    .flatMap(.Concat) { fixture -> SignalProducer<(), NSError> in
        let request = NSURLRequest.create(fixture.URL, nil, contentType: fixture.contentType)
        #if swift(>=2.3)
            let dataURL = baseURL.URLByAppendingPathComponent(fixture.dataFilename as String)!
        #else
            let dataURL = baseURL.URLByAppendingPathComponent(fixture.dataFilename as String)
        #endif
        #if swift(>=2.3)
            let responseURL = baseURL.URLByAppendingPathComponent(fixture.responseFilename as String)!
        #else
            let responseURL = baseURL.URLByAppendingPathComponent(fixture.responseFilename as String)
        #endif
        let path = (dataURL.path! as NSString).stringByAbbreviatingWithTildeInPath
        print("*** Downloading \(request.URL!)\n    to \(path)")
        return session
            .rac_dataWithRequest(request)
            .on(failed: { error in
                print("***** Download failed: \(error)")
            })
            .on(next: { data, response in
                
                let existing = NSData(contentsOfURL: dataURL)
                let changed = existing != data
                
                if changed {
                    try! fileManager.createDirectoryAtURL(dataURL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)

                    let JSONResponse = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    let formattedData = try! NSJSONSerialization.dataWithJSONObject(JSONResponse, options: .PrettyPrinted)
                    formattedData.writeToURL(dataURL, atomically: true)
                }
                
                if changed || !fileManager.fileExistsAtPath(responseURL.path!) {
                    NSKeyedArchiver
                        .archivedDataWithRootObject(response)
                        .writeToURL(responseURL, atomically: true)
                }
            })
            .map { _, _ in () }
    }
    .wait()

if let error = result.error {
    print("Error updating fixtures: \(error)")
}
