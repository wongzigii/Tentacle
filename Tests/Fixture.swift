//
//  Fixtures.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Foundation
@testable import Tentacle


struct Fixture {
    static var endpoints: [Client.Endpoint] = [
        .ReleaseByTagName(owner: "Carthage", repository: "Carthage", tag: "0.15")
    ]
}
