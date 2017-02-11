//
//  periodicTrigger.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Produce a set of triggers spaced apart by time.
    ///
    /// - parameter period: Time between triggers (in seconds). This will update at the start of each trigger. (Default: 1.0)
    ///
    public static func periodicTrigger(period: AKParameter = 1.0) -> AKOperation {
        return AKOperation(module: "dmetro", inputs: period)
    }
}
