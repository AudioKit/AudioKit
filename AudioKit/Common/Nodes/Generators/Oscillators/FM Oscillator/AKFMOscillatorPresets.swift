//
//  AKFMOscillatorPresets.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Preset for the AKFMOscillator
public extension AKFMOscillator {

    /// Stun Ray Preset
    func presetStunRay() {
        baseFrequency = 200
        carrierMultiplier = 90
        modulatingMultiplier = 10
        modulationIndex = 25
    }

    /// Fog Horn Preset
    func presetFogHorn() {
        baseFrequency = 25
        carrierMultiplier = 10
        modulatingMultiplier = 5
        modulationIndex = 10
    }

    /// Buzzer Preset
    func presetBuzzer() {
        baseFrequency = 400
        carrierMultiplier = 28
        modulatingMultiplier = 0.5
        modulationIndex = 100
    }

    /// Spiral Preset
    func presetSpiral() {
        baseFrequency = 5
        carrierMultiplier = 280
        modulatingMultiplier = 0.2
        modulationIndex = 100
    }

    /// Wobble Preset
    func presetWobble() {
        baseFrequency = 20
        carrierMultiplier = 10
        modulatingMultiplier = 0.9
        modulationIndex = 20
    }
}
