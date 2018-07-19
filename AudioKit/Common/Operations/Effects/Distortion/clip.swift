//
//  clip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKComputedParameter {

    /// Clips a signal to a predefined limit, in a "soft" manner.
    ///
    /// - parameter limit: Threshold / limiting value. (Default: 1.0, Minimum: 0.0, Maximum: 1.0)
    ///
    public func clip(_ limit: AKParameter = 1.0) -> AKOperation {
        return AKOperation(module: "clip", inputs: toMono(), limit)
    }
}
