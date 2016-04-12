//
//  AKFMOscillatorPresets.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public extension AKFMOscillator {
    
    /// Stun Ray Preset
    public func presetStunRay() {
        self.baseFrequency = 200
        self.carrierMultiplier = 90
        self.modulatingMultiplier = 10
        self.modulationIndex = 25
    }
    
    /// Fog Horn Preset
    public func presetFogHorn() {
        self.baseFrequency = 25
        self.carrierMultiplier = 10
        self.modulatingMultiplier = 5
        self.modulationIndex = 10
    }
    
    /// Buzzer Preset
    public func presetBuzzer() {
        self.baseFrequency = 400
        self.carrierMultiplier = 28
        self.modulatingMultiplier = 0.5
        self.modulationIndex = 100
    }
    
    /// Spiral Preset
    public func presetSpiral() {
        self.baseFrequency = 5
        self.carrierMultiplier = 280
        self.modulatingMultiplier = 0.2
        self.modulationIndex = 100
    }
    
    
    /// Wobble Preset
    public func presetWobble() {
        self.baseFrequency = 20
        self.carrierMultiplier = 10
        self.modulatingMultiplier = 0.9
        self.modulationIndex = 20
    }

}