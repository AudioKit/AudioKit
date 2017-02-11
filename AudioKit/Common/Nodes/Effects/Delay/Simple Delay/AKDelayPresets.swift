//
//  AKDelayPresets.swift
//  AudioKit
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKDelay
public extension AKDelay {

    /// Short Delay
    public func presetShortDelay() {
        time = 0.125
        feedback = 0.204
        lowPassCutoff = 5_077.644
        dryWetMix = 0.100
    }

    /// Long, dense delay
    public func presetDenseLongDelay() {
        time = 0.795
        feedback = 0.900
        lowPassCutoff = 5_453.823
        dryWetMix = 0.924
    }

    /// Electrical Circuits, Robotic Delay Effect
    public func presetElectricCircuitsDelay() {
        time = 0.025
        feedback = 0.797
        lowPassCutoff = 13_960.832
        dryWetMix = 0.747
    }

    /// Print out current values in case you want to save it as a preset 
    public func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewDelay() {")
        AKLog("    time = \(String(format: "%0.3f", time))")
        AKLog("    feedback = \(String(format: "%0.3f", feedback))")
        AKLog("    lowPassCutoff = \(String(format: "%0.3f", lowPassCutoff))")
        AKLog("    dryWetMix = \(String(format: "%0.3f", dryWetMix))")
        AKLog("}\n")
    }

}
