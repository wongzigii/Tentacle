//
//  Decodable.swift
//  Tentacle
//
//  Created by Matt Diephouse on 3/3/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

import Argo
import Foundation

extension NSURL: Decodable {
    public class func decode(json: JSON) -> Decoded<NSURL> {
        return String.decode(json).flatMap { URLString in
            return .fromOptional(self.init(string: URLString))
        }
    }
}
