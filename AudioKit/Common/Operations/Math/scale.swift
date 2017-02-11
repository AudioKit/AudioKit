//
//  scale.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// This scales from -1 to 1 to a range defined by a minimum and maximum point in the input and output domain.
    ///
    /// - Parameters:
    ///   - minimum: Minimum value to scale to. (Default: 0)
    ///   - maximum: Maximum value to scale to. (Default: 1)
    ///
    public func scale(
        minimum: AKParameter = 0,
        maximum: AKParameter = 1
        ) -> AKOperation {
        return AKOperation(module: "biscale", inputs: self, minimum, maximum)
    }

}
