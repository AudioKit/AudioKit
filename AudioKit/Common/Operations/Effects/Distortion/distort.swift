//
//  distort.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Distortion using a modified hyperbolic tangent function.
    ///
    /// - returns: AKComputedParameter
    /// - parameter input: Input audio signal
    /// - parameter pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion. (Default: 2.0, Minimum: 0.0, Maximum: 10.0)
    /// - parameter postgain: Gain applied after waveshaping (Default: 0.5, Minimum: 0.0, Maximum: 10.0)
    /// - parameter postiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip. (Default: 0.0, Minimum: -10.0, Maximum: 10.0)
    /// - parameter negativeShapeParameter: Like the positive shape parameter, only for the negative part. (Default: 0.0, Minimum: -10.0, Maximum: 10.0)
     ///
    public func distort(
        pregain: AKParameter = 2.0,
        postgain: AKParameter = 0.5,
        postiveShapeParameter: AKParameter = 0.0,
        negativeShapeParameter: AKParameter = 0.0
        ) -> AKOperation {
            return AKOperation("(\(self.toMono()) \(pregain) \(postgain) \(postiveShapeParameter) \(negativeShapeParameter) dist)")
    }
}
