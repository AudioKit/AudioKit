//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Customized by Aurelius Prochazka on 12/21/14.
//
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKInterpolatedRandomNumberPulse()
        operation.frequency = 3.ak
        connect(operation)
        
        let audio = AKOscillator()
        audio.frequency = operation.scaledBy(4000.ak)
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
