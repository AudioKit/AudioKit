// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Preset for the AKMoogLadder
public extension AKMoogLadder {

    /// Blurry, foggy filter
    func presetFogMoogLadder() {
        cutoffFrequency.value = 515.578
        resonance.value = 0.206
    }

    /// Dull noise filter
    func presetDullNoiseMoogLadder() {
        cutoffFrequency.value = 3_088.157
        resonance.value = 0.075
    }

    /// Print out current values in case you want to save it as a preset
    func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewMoogLadderFilter() {")
        AKLog("    cutoffFrequency = \(String(format: "%0.3f", cutoffFrequency.value))")
        AKLog("    resonance = \(String(format: "%0.3f", resonance.value))")
        AKLog("}\n")
    }

}
