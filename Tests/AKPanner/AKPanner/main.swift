//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = Note()
        addNoteProperty(note.pan)
        addNoteProperty(note.panMethod)

        let oscillator = AKOscillator()
        connect(oscillator)

        let pan = AKOscillator()
        pan.frequency = 1.ak
        connect(pan)

        let panner = AKPanner(input: oscillator)
        panner.pan = pan
        connect(panner)

        enableParameterLog(
            "Pan = ",
            parameter: panner.pan,
            timeInterval:0.1
        )

        connect(AKAudioOutput(stereoAudioSource:panner))
    }
}

class Note: AKNote {
    var pan = AKNoteProperty()
    var panMethod = AKNoteProperty()

    override init() {
        super.init()
        addProperty(pan)
        self.pan.setValue(0)
        addProperty(panMethod)
        self.panMethod.setValue(0)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note1 = Note()

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
