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

        let note = CabasaNote()
        let cabasa = AKCabasa()
        cabasa.count = note.count
        cabasa.dampingFactor = note.dampingFactor

        enableParameterLog(
            "Count = ",
            parameter: cabasa.count,
            timeInterval:2
        )

        enableParameterLog(
            "Damping Factor = ",
            parameter: cabasa.dampingFactor,
            timeInterval:2
        )
        setAudioOutput(cabasa)
    }
}

class CabasaNote: AKNote {
    var count = AKNoteProperty()
    var dampingFactor = AKNoteProperty()

    override init() {
        super.init()
        addProperty(count)
        addProperty(dampingFactor)
    }

    convenience init(count: Int, dampingFactor: Float) {
        self.init()
        self.count.floatValue = Float(count)
        self.dampingFactor.floatValue = dampingFactor
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = CabasaNote(count: i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.floatValue = 1.0
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
