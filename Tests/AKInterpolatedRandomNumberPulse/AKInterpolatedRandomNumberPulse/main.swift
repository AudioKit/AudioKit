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

        let interpolatedRandomNumberPulse = AKInterpolatedRandomNumberPulse()
        interpolatedRandomNumberPulse.frequency = 3.ak
        connect(interpolatedRandomNumberPulse)

        let audio = AKOscillator()
        audio.frequency = interpolatedRandomNumberPulse.scaledBy(4000.ak)
        connect(audio)

        enableParameterLog(
            "Frequency = ",
            parameter: audio.frequency,
            timeInterval:0.1
        )

        connect(AKAudioOutput(audioSource:audio))
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
