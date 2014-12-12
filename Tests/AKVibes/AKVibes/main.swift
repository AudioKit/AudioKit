//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Customized by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()
        let note = Note()
        addNoteProperty(note.frequency)
        let operation = AKVibes()
        operation.frequency = note.frequency
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

class Note: AKNote {
    var frequency = AKNoteProperty(value: 220, minimum: 110, maximum: 880)
    override init() {
        super.init()
        addProperty(frequency)
    }
    convenience init(frequency startingFrequency: Float) {
        self.init()
        frequency.setValue(startingFrequency)
    }
}

// Set Up
AKManager.sharedAKManager().fullPathToAudioKit = "/Users/aure/Developer/AudioKit/"
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedAKManager().isLogging = true
AKOrchestra.testForDuration(10)

let note1 = Note(frequency: 440)
let note2 = Note(frequency: 550)
let note3 = Note(frequency: 660)

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
phrase.addNote(note2, atTime:1.0)
phrase.addNote(note3, atTime:1.5)
phrase.addNote(note2, atTime:2.0)

instrument.playPhrase(phrase)

//instrument.playNote(note1, afterDelay:0.5)
//instrument.playNote(note2, afterDelay:1.0)
//instrument.playNote(note3, afterDelay:1.5)
//instrument.playNote(note2, afterDelay:2.0)

while(AKManager.sharedAKManager().isRunning) {} //do nothing
println("Test complete!")
