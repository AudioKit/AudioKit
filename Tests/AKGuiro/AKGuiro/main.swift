//
//  main.swift
//  AudioKit
//
//  Auto-generated on 11/28/14.
//  Customized by Nick Arner on 12/26/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKGuiro()
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(2)
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
