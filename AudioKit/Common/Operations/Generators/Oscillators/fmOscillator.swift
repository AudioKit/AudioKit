//
//  fmOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Classic FM Synthesis audio generation.
    ///
    /// - Parameters:
    ///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency. (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency. (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude. (Default: 1.0, Minimum: 0.0, Maximum: 1000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func fmOscillator(
        baseFrequency baseFrequency: AKParameter = 440,
        carrierMultiplier: AKParameter = 1.0,
        modulatingMultiplier: AKParameter = 1.0,
        modulationIndex: AKParameter = 1.0,
        amplitude: AKParameter = 0.5
        ) -> AKOperation {
            return AKOperation(module: "fm",
                               inputs: baseFrequency, amplitude,
                                       carrierMultiplier, modulatingMultiplier, modulationIndex)
    }
}
