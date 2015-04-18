//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Nick Arner on 12/29/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let adsr = AKADSREnvelope()
        enableParameterLog("ADSR.floatValue = ", parameter: adsr, timeInterval:0.1)

        let oscillator = AKOscillator()
        oscillator.amplitude = adsr

        setAudioOutput(oscillator)
    }
}
AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note1 = AKNote()
let note2 = AKNote()

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
phrase.stopNote(note1, atTime: 2.5)

note2.duration.floatValue = 5.0
phrase.addNote(note2, atTime:3.5)
instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))

