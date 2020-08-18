// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Preset for the AKMoogLadder
public extension AKMoogLadder {

    /// Blurry, foggy filter
    func presetFogMoogLadder() {
        cutoffFrequency = 515.578
        resonance = 0.206
    }

    /// Dull noise filter
    func presetDullNoiseMoogLadder() {
        cutoffFrequency = 3_088.157
        resonance = 0.075
    }

    /// Print out current values in case you want to save it as a preset
    func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewMoogLadderFilter() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency))")
        AKLog("    resonance = \(String(format: "%0.3f", resonance))")
        AKLog("}\n")
    }

}
