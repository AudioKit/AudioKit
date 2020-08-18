// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Preset for the AKCostelloReverb
public extension AKCostelloReverb {

    /// Short Tail Reverb
    func presetShortTailCostelloReverb() {
        cutoffFrequency = 3_849.614
        feedback = 0.172
    }

    /// Low Ringing Long Tail Reverb
    func presetLowRingingLongTailCostelloReverb() {
        cutoffFrequency = 860.435
        feedback = 0.990
    }

    /// Print out current values in case you want to save it as a preset
    func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewReverb() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency))")
        AKLog("    feedback = \(String(format: "%0.3f", feedback))")
        AKLog("}\n")
    }

}
