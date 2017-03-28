//
//  delay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKComputedParameter {

    /// Add a delay to an incoming signal with optional feedback.
    ///
    /// - Parameters:
    ///   - time: Delay time, in seconds. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - feedback: Feedback amount. (Default: 0.0, Minimum: 0.0, Maximum: 1.0)
    ///
    public func delay(
        time: Double = 1.0,
        feedback: AKParameter = 0.0
        ) -> AKOperation {
            return AKOperation(module: "delay",
                               inputs: toMono(), feedback, time)
    }
}
