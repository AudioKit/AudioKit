//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKLowFrequencyOscillatingControl()
        operation.frequency = 2.ak
        operation.amplitude = 20.ak
        connect(operation)

        let audio = AKVCOscillator()
        audio.frequency = operation.plus(440.ak)
        connect(audio)

        connect(AKAudioOutput(audioSource:audio))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")

