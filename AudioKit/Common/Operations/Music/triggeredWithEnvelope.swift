//
//  triggeredWithEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
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
    public func triggeredWithEnvelope(
        _ trigger: AKParameter,
        attack: AKParameter = 0.1,
        hold: AKParameter = 0.3,
        release: AKParameter = 0.2
        ) -> AKOperation {
            return AKOperation("((\(trigger) \(attack) \(hold) \(release) tenv) \(self.toMono()) *)")
    }
}
