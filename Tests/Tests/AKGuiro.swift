//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = GuiroNote()
        let guiro = AKGuiro()
        guiro.count = note.count
        guiro.mainResonantFrequency = note.mainResonantFrequency
        setAudioOutput(guiro)

        enableParameterLog(
            "Count = ",
            parameter: guiro.count,
            timeInterval: 2
        )

        enableParameterLog(
            "Main Resonant Frequency = ",
            parameter: guiro.mainResonantFrequency,
            timeInterval: 2
        )
    }
}

class GuiroNote: AKNote {
    var count = AKNoteProperty()
    var mainResonantFrequency = AKNoteProperty()

    override init() {
        super.init()
        addProperty(count)
        addProperty(mainResonantFrequency)
    }

    convenience init(count: Int, mainResonantFrequency: Float) {
        self.init()
        self.count.floatValue = Float(count)
        self.mainResonantFrequency.floatValue = mainResonantFrequency
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = GuiroNote(count: i*20, mainResonantFrequency: 1000+Float(i)*500)
    note.duration.floatValue = 1.0
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
