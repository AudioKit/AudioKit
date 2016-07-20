//
//  phasor.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Produces a normalized sawtooth wave between the values of 0 and 1. Phasors
    /// are often used when building table-lookup oscillators.
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second, or Hz. (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - phase: Initial phase (Default: 0)
    ///
    public static func phasor(
        frequency frequency: AKParameter = 1,
        phase: Double = 0
        ) -> AKOperation {
        return AKOperation(module: "phasor", inputs: frequency, phase)
    }
}
