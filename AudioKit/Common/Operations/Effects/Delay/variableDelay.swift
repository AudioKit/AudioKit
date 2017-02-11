//
//  variableDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// A delay line with cubic interpolation.
    ///
    /// - Parameters:
    ///   - time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - feedback: Feedback amount. Should be a value between 0-1. (Default: 0.0, Minimum: 0.0, Maximum: 1.0)
    ///   - maximumDelayTime: The maximum delay time, in seconds. (Default: 5.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public func variableDelay(
        time: AKParameter = 1.0,
        feedback: AKParameter = 0.0,
        maximumDelayTime: Double = 5.0
        ) -> AKOperation {
            return AKOperation(module: "vdelay",
                               inputs: toMono(), feedback, time, maximumDelayTime)
    }
}
