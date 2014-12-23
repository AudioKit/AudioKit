//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let sine = AKOscillator()
        connect(sine)

        let position = AKOscillatingControl()
        position.frequency = 0.5.ak
        connect(position)
        
        let operation = AKDopplerEffect(
            audioSource: sine,
            sourcePosition: position.scaledBy(100.ak).plus(100.ak)
        )
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
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
