//
//  AKMoogLadderPresets.swift
//  AudioKit
//
//  Created by Nicholas Arner, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKMoogLadder
public extension AKMoogLadder {
    
    /// Blurry, foggy filter
    public func presetFogMoogLadder() {
        cutoffFrequency = 515.578
        resonance = 0.206
    }
    
    /// Dull noise filter
    public func presetDullNoiseMoogLadder() {
        cutoffFrequency = 3088.157
        resonance = 0.075
    }

}
