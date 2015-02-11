//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = Note()
        addNoteProperty(note.frequency)

        let flute = AKFlute()
        flute.frequency = note.frequency
        connect(flute)

        connect(AKAudioOutput(audioSource:flute))
    }
}

class Note: AKNote {
    var frequency = AKNoteProperty()

    override init() {
        super.init()
        addProperty(frequency)
        self.frequency.setValue(440)
    }

    convenience init(frequency startingFrequency: Float) {
        self.init()
        frequency.setValue(startingFrequency)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true

let note1 = Note(frequency: 440)
note1.duration.setValue(0.5)
let note2 = Note(frequency: 550)
note2.duration.setValue(0.5)
let note3 = Note(frequency: 660)
note3.duration.setValue(0.5)

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
phrase.addNote(note2, atTime:1.0)
phrase.addNote(note3, atTime:1.5)
phrase.addNote(note2, atTime:2.0)

instrument.playPhrase(phrase)


let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
