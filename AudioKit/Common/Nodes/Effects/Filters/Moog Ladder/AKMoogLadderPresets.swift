//
//  AKMoogLadderPresets.swift
//  AudioKit
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Preset for the AKMoogLadder
public extension AKMoogLadder {

    /// Blurry, foggy filter
    public func presetFogMoogLadder() {
        cutoffFrequency = 515.578
        resonance = 0.206
    }

    /// Dull noise filter
    public func presetDullNoiseMoogLadder() {
        cutoffFrequency = 3_088.157
        resonance = 0.075
    }

    /// Print out current values in case you want to save it as a preset
    public func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewMoogLadderFilter() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency))")
        AKLog("    resonance = \(String(format: "%0.3f", resonance))")
        AKLog("    ramp duration = \(String(format: "%0.3f", rampDuration))")
        AKLog("}\n")
    }

}
