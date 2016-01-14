//
//  periodicTrigger.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Produce a set of triggers spaced apart by time.
    ///
    /// - returns: AKOperation
    /// - parameter period: Time between triggers (in seconds). This will update at the start of each trigger. (Default: 1.0)
     ///
    public static func periodicTrigger(period: AKParameter = 1.0) -> AKOperation {
        return AKOperation("(\(period) dmetro)")
    }
}
