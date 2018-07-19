//
//  brownNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKOperation {

    /// Brownian noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0, Maximum: 1.0)
    ///
    public static func brownianNoise(amplitude: AKParameter = 1.0) -> AKOperation {
        return AKOperation(module: "brown *", inputs: amplitude)
    }
}
