//
//  pan.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Panner
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center. (Default: 0, Minimum: -1, Maximum: 1)
    ///
    public func pan(pan: AKParameter = 0) -> AKStereoOperation {
        return AKStereoOperation(module: "pan", inputs: self.toMono(), pan)
    }
}
