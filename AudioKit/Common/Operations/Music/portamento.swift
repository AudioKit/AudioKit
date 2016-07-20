//
//  portamento.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Portamento-style control signal smoothing
    /// Useful for smoothing out low-resolution signals and applying glissando to
    /// filters.
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - halfDuration: Duration which the curve will traverse half the distance towards the new value, then half as much again, etc., theoretically never reaching its asymptote. (Default: 0.02, Minimum: , Maximum: )
    ///
    public func portamento(halfDuration halfDuration: AKParameter = 0.02) -> AKOperation {
        return AKOperation(module: "port", inputs: self, halfDuration)
    }
}
