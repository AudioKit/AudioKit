//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/29/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 2.0

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

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note = AKNote()
note.duration.floatValue = 1

instrument.playNote(note)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
