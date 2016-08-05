//
//  smoothDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {
    
    /// Smooth variable delay line without varispeed pitch.
    ///
    /// - Parameters:
    ///   - time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - samplesls: Interpolation samples
    ///   - feedback: Feedback amount. Should be a value between 0-1. (Default: 0.0, Minimum: 0.0, Maximum: 1.0)
    ///   - maximumDelayTime: The maximum delay time, in seconds. (Default: 5.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public func smoothDelay(
        time time: AKParameter = 1.0,
             samples: AKParameter = 1024,
             feedback: AKParameter = 0.0,
             maximumDelayTime: Double = 1.0
        ) -> AKOperation {
        return AKOperation(module: "smoothdelay",
                           inputs: self.toMono(), feedback, time, maximumDelayTime, samples)
    }
}
