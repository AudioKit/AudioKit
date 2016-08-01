//
//  delay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKComputedParameter {

    /// Add a delay to an incoming signal with optional feedback.
    ///
    /// - Parameters:
    ///   - time: Delay time, in seconds. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - feedback: Feedback amount. (Default: 0.0, Minimum: 0.0, Maximum: 1.0)
    ///
    public func delay(
        time time: Double = 1.0,
        feedback: AKParameter = 0.0
        ) -> AKOperation {
            return AKOperation(module: "delay",
                               inputs: self.toMono(), feedback, time)
    }
}
