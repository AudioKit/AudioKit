//
//  metronome.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Metro produces a series of 1-sample ticks at a regular rate. Typically, this
    /// is used alongside trigger-driven modules.
    ///
    /// - parameter frequency: The frequency to repeat. (Default: 2.0)
    ///
    public static func metronome(frequency: AKParameter = 2.0) -> AKOperation {
        return AKOperation(module: "metro", inputs: frequency)
    }
}
