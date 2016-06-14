//
//  lowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// A first-order recursive low-pass filter with variable frequency response.
    ///
    /// - returns: AKComputedParameter
    /// - parameter input: Input audio signal
    /// - parameter halfPowerPoint: The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2. (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
     ///
    public func lowPassFilter(
        halfPowerPoint: AKParameter = 1000
        ) -> AKOperation {
            return AKOperation("(\(self.toMono()) \(halfPowerPoint) tone)")
    }
}
