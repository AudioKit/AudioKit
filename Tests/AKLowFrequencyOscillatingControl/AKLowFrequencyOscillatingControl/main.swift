//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Customized by Aurelius Prochazka on 12/22/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let operation = AKLowFrequencyOscillatingControl()
        operation.frequency = 2.ak
        operation.amplitude = 20.ak
        connect(operation)
        
        let audio = AKVCOscillator(frequency: operation.plus(440.ak), amplitude: akp(1))
        connect(audio)
        
        connect(AKAudioOutput(audioSource:audio))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")

