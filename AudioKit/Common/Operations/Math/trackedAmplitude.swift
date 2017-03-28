//
//  trackedAmplitude.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKComputedParameter {

    /// Panner
    ///
    /// - parameter input: Input audio signal
    ///
    public func trackedAmplitude(_ trackedAmplitude: AKParameter = 0) -> AKOperation {
        return AKOperation(module: "rms", inputs: toMono())
    }
}
