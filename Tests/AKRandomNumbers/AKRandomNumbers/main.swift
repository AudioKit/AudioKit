//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let randomWidth = AKRandomNumbers()
        connect(randomWidth)

        let oscillator = AKOscillator()
        oscillator.frequency = 440.ak.plus(randomWidth.scaledBy(100.ak))
        connect(oscillator)

        connect(AKAudioOutput(audioSource:oscillator))
    }
}

AKOrchestra.testForDuration(2)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")

