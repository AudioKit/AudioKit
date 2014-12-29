//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let source = AKTambourine()
        connect(source)

        let operation = AKSimpleWaveGuideModel(
            input: source
        )
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
