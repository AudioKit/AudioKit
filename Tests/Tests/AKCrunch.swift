//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = CrunchNote()
        let crunch = AKCrunch()
        crunch.intensity = note.intensity
        crunch.dampingFactor = note.dampingFactor

        enableParameterLog(
            "Intensity = ",
            parameter: crunch.intensity,
            timeInterval:1
        )
        enableParameterLog(
            "Damping Factor = ",
            parameter: crunch.dampingFactor,
            timeInterval:1
        )
        setAudioOutput(crunch)
    }
}

class CrunchNote: AKNote {
    var intensity = AKNoteProperty()
    var dampingFactor = AKNoteProperty()

    override init() {
        super.init()
        addProperty(intensity)
        addProperty(dampingFactor)
    }

    convenience init(intensity: Int, dampingFactor: Float) {
        self.init()
        self.intensity.floatValue = Float(intensity)
        self.dampingFactor.floatValue = dampingFactor
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = CrunchNote(intensity: 40+i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.floatValue = 1.0
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
