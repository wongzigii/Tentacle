//
//  ResourceType.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/10/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo

/// A Resource from the GitHub API.
protocol ResourceType: Decodable {
    static func decode(json: JSON) -> Decoded<Self>
}
