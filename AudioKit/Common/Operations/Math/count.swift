//
//  count.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 11/4/16.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Keep track of the number of times a trigger has fired
    ///
    /// - Parameters:
    ///   - maximum: Largest value to hold before looping or being pinned to this value
    ///   - looping: If set to true, when the maximum is reaching, the count goes back to zero, otherwise it stays at the maximum
    ///
    public func count(maximum: AKParameter = 1_000_000, looping: Bool = true) -> AKOperation {
        return AKOperation(module: "count", inputs: toMono(), maximum, looping ? 0 : 1)
    }
}
