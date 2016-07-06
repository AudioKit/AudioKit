//
//  AKMandolinPresets.swift
//  AudioKit 
//
//  Created by Nicholas Arner on 7/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Preset for the AKMandolin
public extension AKMandolin {
    
    public func presetLargeResonantMandolin() {
        detune = 0.503
        bodySize = 2.865
    }

    public func presetElectricGuitarMandolin() {
        detune = 0.996
        bodySize = 1.954
    }

    public func presetSmallBodiedDistortedMandolin() {
        detune = 1.508
        bodySize = 0.375
    }
    
    public func presetAcidMandolin() {
        detune = 1.876
        bodySize = 2.948
    }
    

}