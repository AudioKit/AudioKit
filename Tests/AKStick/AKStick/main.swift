//
//  main.swift
//  AudioKit
//
//  Auto-generated on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKStick()
        operation.intensity = 10.ak
        operation.dampingFactor = 0.9.ak
        operation.amplitude = 2.ak
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(1)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
