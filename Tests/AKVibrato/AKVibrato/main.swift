//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let vibrato = AKVibrato()
        vibrato.averageAmplitude = 20.ak
        connect(vibrato)

        let sine = AKOscillator()
        sine.frequency = 440.ak.plus(vibrato)
        connect(sine)

        enableParameterLog(
            "Frequency = ",
            parameter: sine.frequency,
            timeInterval:0.1
        )

        connect(AKAudioOutput(audioSource:sine))
    }
}


let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
