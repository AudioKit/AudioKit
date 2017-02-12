//
//  pan.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKComputedParameter {

    /// Panner
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center. (Default: 0, Minimum: -1, Maximum: 1)
    ///
    public func pan(_ pan: AKParameter = 0) -> AKStereoOperation {
        return AKStereoOperation(module: "pan", inputs: toMono(), pan)
    }
}
