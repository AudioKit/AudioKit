//
//  adsrEnvelope.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 3/21/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /// Trigger based linear AHD envelope generator
    ///
    /// - returns: AKOperation
    /// - parameter trigger: A triggering operation such as a metronome
    /// - parameter attack: Attack time, in seconds. (Default: 0.1)
    /// - parameter hold: Hold time, in seconds. (Default: 0.3)
    /// - parameter release: Release time, in seconds. (Default: 0.2)
    ///
    public func gatedADSREnvelope(
        gate: AKParameter,
        attack:  AKParameter = 0.1,
        decay:   AKParameter = 0.0,
        sustain: AKParameter = 1,
        release: AKParameter = 0.2
        ) -> AKOperation {
        return AKOperation("((\(gate) \(attack) \(decay) \(sustain) \(release) adsr) \(self.toMono()) *)")
    }
}
