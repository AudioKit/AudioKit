//
//  AKDistortionPresets.swift
//  AudioKit 
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
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
        print("public func presetSomeNewDistortion() {")
        print("    delay = \(String(format: "%0.3f", delay))")
        print("    decay = \(String(format: "%0.3f", decay))")
        print("    delayMix = \(String(format: "%0.3f", delayMix))")
        print("    linearTerm = \(String(format: "%0.3f", linearTerm))")
        print("    squaredTerm = \(String(format: "%0.3f", squaredTerm))")
        print("    cubicTerm = \(String(format: "%0.3f", cubicTerm))")
        print("    polynomialMix = \(String(format: "%0.3f", polynomialMix))")
        print("    softClipGain = \(String(format: "%0.3f", softClipGain))")
        print("    finalMix = \(String(format: "%0.3f", finalMix))")
        print("}\n")
    }
}
