//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/14/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let cosineTable = AKAdditiveCosineTable()
        connect(cosineTable)

        let operation = AKAdditiveCosines(
            cosineTable: cosineTable
        )
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
