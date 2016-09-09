//
//  bitCrush.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// This will digitally degrade a signal.
    ///
    /// - Parameters:
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. (Default: 8, Minimum: 1, Maximum: 24)
    ///   - sampleRate: The sample rate of signal output. (Default: 10000, Minimum: 0.0, Maximum: 20000.0)
    ///
    public func bitCrush(
        bitDepth: AKParameter = 8,
        sampleRate: AKParameter = 10000
        ) -> AKOperation {
        return AKOperation(module: "bitcrush",
                           inputs: self.toMono(), bitDepth, sampleRate)
    }
}
