//
//  triggeredWithEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
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
    public func triggeredWithEnvelope(
        trigger: AKParameter,
        attack: AKParameter = 0.1,
        hold: AKParameter = 0.3,
        release: AKParameter = 0.2
        ) -> AKOperation {
        return AKOperation(module: "tenv *", inputs: self, trigger, attack, hold, release)
    }
}
