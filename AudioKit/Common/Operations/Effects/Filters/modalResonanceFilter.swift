//
//  modalResonanceFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKComputedParameter {

    /// A modal resonance filter used for modal synthesis. Plucked and bell sounds
    /// can be created using  passing an impulse through a combination of modal
    /// filters.
    ///
    /// - Parameters:
    ///   - frequency: Resonant frequency of the filter. (Default: 500.0, Minimum: 12.0, Maximum: 20000.0)
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency. 
    ///                    (Default: 50.0, Minimum: 0.0, Maximum: 100.0)
    ///
    public func modalResonanceFilter(
        frequency: AKParameter = 500.0,
        qualityFactor: AKParameter = 50.0
        ) -> AKOperation {
            return AKOperation(module: "mode", inputs: toMono(), frequency, qualityFactor)
    }
}
