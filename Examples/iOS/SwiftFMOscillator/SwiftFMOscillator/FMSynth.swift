//
//  FMSynth.swift
//  SwiftFMOscillator
//
//  Created by Aurelius Prochazka on 7/5/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

class FMSynth: AKInstrument {
    
    // INSTRUMENT CONTROLS =====================================================
    
    var frequency            = AKInstrumentProperty(value: 440, minimum: 20, maximum: 2000)
    var amplitude            = AKInstrumentProperty(value: 0.2, minimum: 0,  maximum: 1)
    var carrierMultiplier    = AKInstrumentProperty(value: 1,   minimum: 0,  maximum: 3)
    var modulatingMultiplier = AKInstrumentProperty(value: 1,   minimum: 0,  maximum: 3)
    var modulationIndex      = AKInstrumentProperty(value: 15,  minimum: 0,  maximum: 30)
    
    // INSTRUMENT DEFINITION ===================================================
    
    override init() {
        super.init()
        
        addProperty(frequency)
        addProperty(amplitude)
        addProperty(carrierMultiplier)
        addProperty(modulatingMultiplier)
        addProperty(modulationIndex)
        
        let sine = AKSineTable()
        addFTable(sine)

        let fmOscillator = AKFMOscillator(
            FTable: sine,
            baseFrequency: frequency,
            carrierMultiplier: carrierMultiplier,
            modulatingMultiplier: modulatingMultiplier,
            modulationIndex: modulationIndex,
            amplitude: amplitude,
            phase: 0.ak
        )
        connect(fmOscillator)
        connect(AKAudioOutput(audioSource: fmOscillator))
    }
}