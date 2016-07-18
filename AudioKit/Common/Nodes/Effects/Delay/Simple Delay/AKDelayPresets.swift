//
//  AKDelayPresets.swift
//  AudioKit
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKDelay
public extension AKDelay {

    /// Short Delay
    public func presetShortDelay() {
        time = 0.125
        feedback = 0.204
        lowPassCutoff = 5077.644
        dryWetMix = 0.100
    }
    
    /// Long, dense delay
    public func presetDenseLongDelay() {
        time = 0.795
        feedback = 0.900
        lowPassCutoff = 5453.823
        dryWetMix = 0.924
    }
    
    /// Electrical Circuits, Robotic Delay Effect
    public func presetElectricCircuitsDelay() {
        time = 0.025
        feedback = 0.797
        lowPassCutoff = 13960.832
        dryWetMix = 0.747
    }
    
}