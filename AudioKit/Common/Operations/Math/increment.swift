//
//  increment.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {

    /// Increment a signal by a default value of 1
    ///
    /// - Parameters:
    ///   - on: When to increment
    ///   - by: Increment amount (Default: 1)
    ///   - minimum: Increment amount (Default: 1)
    ///   - maximum: Increment amount (Default: 1)
    ///
    public func increment(on trigger: AKParameter,
                          by step: AKParameter = 1.0,
                          minimum: AKParameter = 0.0,
                          maximum: AKParameter = 1_000_000) -> AKOperation {
        return AKOperation(module: "incr", inputs: trigger, step, minimum, maximum, toMono())
    }
}
