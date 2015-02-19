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

let note1 = AKNote()
note1.duration.setValue(1)

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
