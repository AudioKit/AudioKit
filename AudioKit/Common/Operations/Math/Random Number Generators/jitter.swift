//
//  jitter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// A signal with random fluctuations
    /// This is useful for emulating jitter found in analogue equipment.
    ///
    /// - Parameters:
    ///   - amplitude: The amplitude of the line. Will produce values in the range of (+/-)amp. (Default: 0.5)
    ///   - minimumFrequency: The minimum frequency of change in Hz. (Default: 0.5)
    ///   - maximumFrequency: The maximum frequency of change in Hz. (Default: 4)
    ///
    public static func jitter(
        amplitude: AKParameter = 0.5,
        minimumFrequency: AKParameter = 0.5,
        maximumFrequency: AKParameter = 4
        ) -> AKOperation {
        return AKOperation(module: "jitter",
                           inputs: amplitude, minimumFrequency, maximumFrequency)
    }
}
