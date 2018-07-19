//
//  lowPassButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKComputedParameter {

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func lowPassButterworthFilter(
        cutoffFrequency: AKParameter = 1_000
        ) -> AKOperation {
        return AKOperation(module: "butlp", inputs: toMono(), cutoffFrequency)
    }
}
