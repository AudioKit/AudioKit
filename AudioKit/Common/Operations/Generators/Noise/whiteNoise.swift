//
//  whiteNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKOperation {

    /// White noise generator
    ///
    /// - parameter amplitude: Amplitude. (Value between 0-1). (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public static func whiteNoise(
        amplitude: AKParameter = 1.0
        ) -> AKOperation {
        return AKOperation(module: "noise", inputs: amplitude)
    }
}
