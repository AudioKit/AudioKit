//
//  AKDistortionPresets.swift
//  AudioKit 
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

/// Preset for the AKDistortion
public extension AKDistortion {

    /// Massive Distortion
    public func presetInfiniteDistortionWall() {
        delay = 475.776
        decay = 40.579
        delayMix = 0.820
        linearTerm = 0.760
        squaredTerm = 0.729
        cubicTerm = 1.000
        polynomialMix = 0.500
        softClipGain = -8.441
        finalMix = 0.798
    }

    /// Print out current values in case you want to save it as a preset
    public func printCurrentValuesAsPreset() {
        AKLog("public func presetSomeNewDistortion() {")
        AKLog("    delay = \(String(format: "%0.3f", delay))")
        AKLog("    decay = \(String(format: "%0.3f", decay))")
        AKLog("    delayMix = \(String(format: "%0.3f", delayMix))")
        AKLog("    linearTerm = \(String(format: "%0.3f", linearTerm))")
        AKLog("    squaredTerm = \(String(format: "%0.3f", squaredTerm))")
        AKLog("    cubicTerm = \(String(format: "%0.3f", cubicTerm))")
        AKLog("    polynomialMix = \(String(format: "%0.3f", polynomialMix))")
        AKLog("    softClipGain = \(String(format: "%0.3f", softClipGain))")
        AKLog("    finalMix = \(String(format: "%0.3f", finalMix))")
        AKLog("}\n")
    }
}
