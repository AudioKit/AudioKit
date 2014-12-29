//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let frequencyShifter = AKLowFrequencyOscillator()
        frequencyShifter.type = AKLowFrequencyOscillatorType.BipolarSquare
        frequencyShifter.amplitude = 100.ak;
        frequencyShifter.frequency = 0.25.ak
        connect(frequencyShifter)

        let operation = AKPortamento(input: frequencyShifter)
        connect(operation)

        let sine = AKOscillator()
        sine.frequency  = operation.plus(880.ak)
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
