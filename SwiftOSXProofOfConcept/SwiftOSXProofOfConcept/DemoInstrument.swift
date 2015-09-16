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
    var filter: AKDecimator
    
    var playNote = AKTrigger()
    override init() {
        
        // Method 1: Full Initializer
        oscillatingFrequency = AKOscillator(
            waveform: AKTable.standardSquareWave(),
            frequency: akp(0.1),
            amplitude: akp(44),
            phase: 0.0
        )
        
        // Method 2: Default Initializer plus property setting
        oscillatingFrequency = AKOscillator()
        oscillatingFrequency.waveform  = AKTable.standardSquareWave()
        oscillatingFrequency.frequency = akp(0.1)
        oscillatingFrequency.amplitude = akp(44)
        
        // Method 1: Full Initializer
        fmOscillator = AKFMOscillator(
            waveform: AKTable.standardTriangleWave(),
            baseFrequency: oscillatingFrequency,
            carrierMultiplier: akp(3),
            modulatingMultiplier: akp(5),
            modulationIndex: akp(11),
            amplitude: akp(0.1)
        )
        
        // Method 2: Default Initializer plus property setting
        fmOscillator = AKFMOscillator()
        fmOscillator.waveform             = AKTable.standardSquareWave()
        fmOscillator.baseFrequency        = oscillatingFrequency
        fmOscillator.carrierMultiplier    = 3.ak
        fmOscillator.modulatingMultiplier = 5.ak
        fmOscillator.modulationIndex      = 11.ak
        fmOscillator.amplitude            = 0.5.ak
        
        // Method 3: Default initializer and resetting values
        fmOscillator = AKFMOscillator()
        fmOscillator.waveform      = AKTable.standardSquareWave()
        fmOscillator.baseFrequency = oscillatingFrequency
        fmOscillator.carrierMultiplier.value    = 3
        fmOscillator.modulatingMultiplier.value = 5
        fmOscillator.modulationIndex.value      = 11
        fmOscillator.amplitude.value            = 0.5
        
        let distortion = AKDistortion(input: fmOscillator)

        //fmOscillator = AKFMOscillator.presetWobble()
        
        let simple = AKOscillator()
        simple.waveform = AKTable.standardSquareWave()
        simple.frequency.value = 880
        simple.amplitude.value = 1.0
        
        filter = AKDecimator(input: fmOscillator)
        let reverb = AKReverb(input: distortion)

        super.init()
        output = reverb
        
    }
    
}