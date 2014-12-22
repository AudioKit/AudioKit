//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/22/14.
//  Customized by Aurelius Prochazka on 12/22/14.
//
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let operation = AKLowFrequencyOscillatingControl()
        operation.frequency = 1.ak;
        connect(operation)
        
        let audio = AKOscillator()
        audio.frequency = 440.ak.plus(operation.scaledBy(100.ak))
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

