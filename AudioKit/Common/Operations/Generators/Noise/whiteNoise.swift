//
//  whiteNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKOperation {

    /// White noise generator
    ///
    /// - parameter amplitude: Overall level. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func whiteNoise(amplitude: AKParameter = 1.0) -> AKOperation {
        return AKOperation(module: "noise", inputs: amplitude)
    }
}
