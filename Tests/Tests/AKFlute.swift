//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 5.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = Note()
        let flute = AKFlute()
        flute.frequency = note.frequency
        setAudioOutput(flute)
    }
}

class Note: AKNote {
    var frequency = AKNoteProperty()

    override init() {
        super.init()
        addProperty(frequency)
        self.frequency.floatValue = 440
    }

    convenience init(frequency startingFrequency: Float) {
        self.init()
        frequency.floatValue = startingFrequency
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true

let note1 = Note(frequency: 440)
note1.duration.floatValue = 0.5
let note2 = Note(frequency: 550)
note2.duration.floatValue = 0.5
let note3 = Note(frequency: 660)
note3.duration.floatValue = 0.5

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
phrase.addNote(note2, atTime:1.0)
phrase.addNote(note3, atTime:1.5)
phrase.addNote(note2, atTime:2.0)

instrument.playPhrase(phrase)


NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
