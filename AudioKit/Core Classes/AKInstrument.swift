//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

@objc class AKInstrument {
    var operations: [AKParameter] = []
    
    var oscillatingFrequency: AKOscillator
    var fmOscillator: AKFMOscillator
    
    init() {
        
        // Method 1: Full Initializer
        oscillatingFrequency = AKOscillator(
            frequency: akp(1),
            amplitude: akp(440),
            phase: 0.0
        )
        
        // Method 2: Default Initializer plus property setting
        oscillatingFrequency = AKOscillator()
        oscillatingFrequency.frequency = akp(1)
        oscillatingFrequency.amplitude = akp(440)
        
        // Method 1: Full Initializer
        fmOscillator = AKFMOscillator(
            baseFrequency: oscillatingFrequency,
            carrierMultiplier: akp(3),
            modulatingMultiplier: akp(5),
            modulationIndex: akp(11),
            amplitude: akp(0.1)
        )
        
        // Method 2: Default Initializer plus property setting
        fmOscillator = AKFMOscillator()
        fmOscillator.baseFrequency        = oscillatingFrequency
        fmOscillator.carrierMultiplier    = akp(3)
        fmOscillator.modulatingMultiplier = akp(5)
        fmOscillator.modulationIndex      = akp(11)
        fmOscillator.amplitude            = akp(0.1)
        
        operations.append(oscillatingFrequency)
        operations.append(fmOscillator)
    }

}