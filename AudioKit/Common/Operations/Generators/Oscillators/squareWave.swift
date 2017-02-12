//
//  squareWave.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {

    /// This is a bandlimited square oscillator ported from the "square" function
    /// from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0, Maximum: 20000)
    ///   - amplitude: Output amplitude (Default: 1.0, Minimum: 0, Maximum: 10)
    ///   - pulseWidth: Duty cycle width (range 0-1). (Default: 0.5, Minimum: 0, Maximum: 1)
    ///
    public static func squareWave(
        frequency: AKParameter = 440,
        amplitude: AKParameter = 1.0,
        pulseWidth: AKParameter = 0.5
        ) -> AKOperation {
            return AKOperation(module: "blsquare",
                               inputs: frequency, amplitude, pulseWidth)
    }
}
