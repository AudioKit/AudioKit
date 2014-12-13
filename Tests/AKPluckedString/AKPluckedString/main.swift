//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/28/14.
//  Modified by Aurelius Prochazka on 11/28/14 to include excitation signal.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let oscil = AKOscillator(
            FTable: AKManager.standardSineTable,
            frequency: 1.ak,
            amplitude: 1.ak)
        connect(oscil)

        let operation = AKPluckedString(excitationSignal: oscil)
        operation.setOptionalPluckPosition(0.01.ak)
        operation.setOptionalReflectionCoefficient(0.7.ak)
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.test()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
