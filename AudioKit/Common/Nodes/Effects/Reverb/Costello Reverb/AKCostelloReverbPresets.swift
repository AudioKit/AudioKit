//
//  AKCostelloReverbPresets.swift
//  AudioKit 
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKCostelloReverb
public extension AKCostelloReverb {

    /// Short Tail Reverb
    public func presetShortTailCostelloReverb() {
        cutoffFrequency = 3849.614
        feedback = 0.172
    }
    
    /// Low Ringing Long Tail Reverb
    public func presetLowRingingLongTailCostelloReverb() {
        cutoffFrequency = 860.435
        feedback = 0.990
    }
    
    
    /// Print out current values in case you want to save it as a preset
    public func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewReverb() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency))")
        AKLog("    feedback = \(String(format: "%0.3f", feedback))")
        AKLog("}\n")
    }

}
