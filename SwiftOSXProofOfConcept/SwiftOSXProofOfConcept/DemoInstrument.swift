//
//  DemoInstrument.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/7/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import Foundation

class DemoInstrument: AKInstrument {

    var oscillatingFrequency: AKOscillator
    var fmOscillator: AKFMOscillator
    var panner: AKPanner
    
    override init() {
        
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
        fmOscillator.carrierMultiplier    = 3.ak
        fmOscillator.modulatingMultiplier = 5.ak
        fmOscillator.modulationIndex      = 11.ak
        fmOscillator.amplitude            = 0.5.ak
        
        // Method 3: Default initializer and resetting values
        fmOscillator = AKFMOscillator()
        fmOscillator.baseFrequency = oscillatingFrequency
        fmOscillator.carrierMultiplier.value    = 3
        fmOscillator.modulatingMultiplier.value = 5
        fmOscillator.modulationIndex.value      = 11
        fmOscillator.amplitude.value            = 0.5
        
        let simple = AKOscillator()
        simple.frequency.value = 880
        simple.amplitude.value = 1.0
        
        panner = AKPanner(input: fmOscillator)
        let reverb = AKReverb(input: panner)

        let output = AKAudioOutput(input:reverb)
        
        super.init()
        
        operations.append(oscillatingFrequency)
        operations.append(fmOscillator)
        operations.append(simple)
        operations.append(panner)
        operations.append(reverb)
        operations.append(output)
        
    }
    
}