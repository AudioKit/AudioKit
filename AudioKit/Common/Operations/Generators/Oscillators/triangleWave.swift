//
//  triangleWave.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {

    /// This is a bandlimited triangle oscillator
    /// ported from the "triangle" function from the Faust programming language.
    ///
    /// - Parameters:
    ///   - frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    ///   - amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func triangleWave(
        frequency: AKParameter = 440,
        amplitude: AKParameter = 0.5
        ) -> AKOperation {
            return AKOperation(module: "bltriangle", inputs: frequency, amplitude)
    }
}
