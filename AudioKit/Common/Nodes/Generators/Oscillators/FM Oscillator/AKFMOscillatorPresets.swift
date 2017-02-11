//
//  AKFMOscillatorPresets.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKFMOscillator
public extension AKFMOscillator {

    /// Stun Ray Preset
    public func presetStunRay() {
        baseFrequency = 200
        carrierMultiplier = 90
        modulatingMultiplier = 10
        modulationIndex = 25
    }

    /// Fog Horn Preset
    public func presetFogHorn() {
        baseFrequency = 25
        carrierMultiplier = 10
        modulatingMultiplier = 5
        modulationIndex = 10
    }

    /// Buzzer Preset
    public func presetBuzzer() {
        baseFrequency = 400
        carrierMultiplier = 28
        modulatingMultiplier = 0.5
        modulationIndex = 100
    }

    /// Spiral Preset
    public func presetSpiral() {
        baseFrequency = 5
        carrierMultiplier = 280
        modulatingMultiplier = 0.2
        modulationIndex = 100
    }

    /// Wobble Preset
    public func presetWobble() {
        baseFrequency = 20
        carrierMultiplier = 10
        modulatingMultiplier = 0.9
        modulationIndex = 20
    }
}
