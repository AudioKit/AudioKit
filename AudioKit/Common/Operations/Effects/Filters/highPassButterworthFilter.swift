//
//  highPassButterworthFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// These filters are Butterworth second-order IIR filters. They offer an almost
    /// flat passband and very good precision and stopband attenuation.
    ///
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz) (Default: 500, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassButterworthFilter(
        cutoffFrequency cutoffFrequency: AKParameter = 500
        ) -> AKComputedParameter {
            return AKOperation("(\(self.toMono()) \(cutoffFrequency) buthp)")
    }
}
