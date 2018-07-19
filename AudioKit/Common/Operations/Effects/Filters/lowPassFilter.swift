//
//  lowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKComputedParameter {

    /// A first-order recursive low-pass filter with variable frequency response.
    ///
    /// - parameter halfPowerPoint: The response curve's half-power point, in Hertz. Half power is defined as
    ///                             peak power / root 2. (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func lowPassFilter(
        halfPowerPoint: AKParameter = 1_000
        ) -> AKOperation {
        return AKOperation(module: "tone", inputs: toMono(), halfPowerPoint)
    }
}
