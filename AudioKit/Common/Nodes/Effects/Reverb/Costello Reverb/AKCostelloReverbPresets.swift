// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Preset for the AKCostelloReverb
public extension AKCostelloReverb {

    /// Short Tail Reverb
    func presetShortTailCostelloReverb() {
        cutoffFrequency.value = 3_849.614
        feedback.value = 0.172
    }

    /// Low Ringing Long Tail Reverb
    func presetLowRingingLongTailCostelloReverb() {
        cutoffFrequency.value = 860.435
        feedback.value = 0.990
    }

    /// Print out current values in case you want to save it as a preset
    func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewReverb() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency.value))")
        AKLog("    feedback = \(String(format: "%0.3f", feedback.value))")
        AKLog("}\n")
    }

}
