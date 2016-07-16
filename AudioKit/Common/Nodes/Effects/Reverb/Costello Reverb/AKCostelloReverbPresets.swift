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

    public func presetShortTailCostelloReverb() {
        cutoffFrequency = 3849.614
        feedback = 0.172
    }
    
    public func presetLowRingingLongTailCostelloReverb() {
        cutoffFrequency = 860.435
        feedback = 0.990
    }

}