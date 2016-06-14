//
//  metronome.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Metro produces a series of 1-sample ticks at a regular rate. Typically, this
    /// is used alongside trigger-driven modules.
    ///
    /// - returns: AKOperation
    /// - parameter frequency: The frequency to repeat. (Default: 2.0)
     ///
    public static func metronome(_ frequency: AKParameter = 2.0) -> AKOperation {
        return AKOperation("(\(frequency) metro)")
    }
}
