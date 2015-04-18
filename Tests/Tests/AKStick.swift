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

        let note = StickNote()
        let stick = AKStick()
        stick.intensity = note.intensity
        stick.dampingFactor = note.dampingFactor
        setAudioOutput(stick)

        enableParameterLog(
            "Intensity = ",
            parameter: stick.intensity,
            timeInterval:1
        )
        enableParameterLog(
            "Damping Factor = ",
            parameter: stick.dampingFactor,
            timeInterval:1
        )
    }
}

class StickNote: AKNote {
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

for i in 1...20 {
    let note = StickNote(intensity: i*20, dampingFactor: 1.05-Float(i)/20.0)
    note.duration.floatValue = 0.5
    phrase.addNote(note, atTime: Float(i-1)*0.5)
}

instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
