//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKVibrato()
        operation.averageAmplitude = 20.ak
        connect(operation)

        let sine = AKOscillator()
        sine.frequency = 440.ak.plus(operation)
        connect(sine)

        connect(AKAudioOutput(audioSource:sine))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
