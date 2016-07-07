//
//  adsrEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/21/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Trigger based linear AHD envelope generator
    ///
    /// - Parameters:
    ///   - trigger: A triggering operation such as a metronome
    ///   - attack: Attack time, in seconds. (Default: 0.1)
    ///   - hold: Hold time, in seconds. (Default: 0.3)
    ///   - release: Release time, in seconds. (Default: 0.2)
    ///
    public func gatedADSREnvelope(
        gate: AKParameter,
        attack:  AKParameter = 0.1,
        decay:   AKParameter = 0.0,
        sustain: AKParameter = 1,
        release: AKParameter = 0.2
        ) -> AKOperation {
        var sustainLevel = "0.00000001"
        if Double(sustain.description) > 0 {
            sustainLevel = sustain.description
        }
        return AKOperation("((\(gate) \(attack) \(decay) \(sustainLevel) \(release) adsr) \(self.toMono()) *)")
    }
}
