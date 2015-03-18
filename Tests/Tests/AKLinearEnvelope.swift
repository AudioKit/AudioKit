//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/29/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let envelope = AKLinearEnvelope()
        enableParameterLog("Envelope value = ", parameter: envelope, timeInterval:0.02)

        let oscillator = AKOscillator()
        oscillator.amplitude = envelope

        setAudioOutput(oscillator)
    }
}

AKOrchestra.testForDuration(2)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note = AKNote()
note.duration.value = 1

instrument.playNote(note)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
