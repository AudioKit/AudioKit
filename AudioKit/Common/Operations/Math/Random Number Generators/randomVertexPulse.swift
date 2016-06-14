//
//  randomVertexPulse.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Line segments with vertices at random points
    ///
    /// - returns: AKOperation
    /// - parameter minimum: Minimum value (Default: 0)
    /// - parameter maximum: Maximum value (Default: 1)
    /// - parameter updateFrequency: Frequency to change values. (Default: 3)
     ///
    public static func randomVertexPulse(
        minimum: AKParameter = 0,
        maximum: AKParameter = 1,
        updateFrequency: AKParameter = 3
        ) -> AKOperation {
            return AKOperation("(\(minimum) \(maximum) \(updateFrequency) randi)")
    }
}
