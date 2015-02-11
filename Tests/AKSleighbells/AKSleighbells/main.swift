//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/17/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = Note()
        addNoteProperty(note.intensity)
        addNoteProperty(note.dampingFactor)
        addNoteProperty(note.mainResonantFrequency)
        addNoteProperty(note.firstResonantFrequency)
        addNoteProperty(note.secondResonantFrequency)

        let sleighbells = AKSleighbells()
        sleighbells.intensity = note.intensity
        sleighbells.dampingFactor = note.dampingFactor
        sleighbells.mainResonantFrequency = note.mainResonantFrequency
        sleighbells.firstResonantFrequency = note.firstResonantFrequency
        sleighbells.secondResonantFrequency = note.secondResonantFrequency
        connect(sleighbells)

        connect(AKAudioOutput(audioSource:sleighbells))
    }
}

class Note: AKNote {
    var intensity = AKNoteProperty()
    var dampingFactor = AKNoteProperty()
    var mainResonantFrequency = AKNoteProperty()
    var firstResonantFrequency = AKNoteProperty()
    var secondResonantFrequency = AKNoteProperty()

    override init() {
        super.init()
        addProperty(intensity)
        self.intensity.setValue(32)
        addProperty(dampingFactor)
        self.dampingFactor.setValue(0.2)
        addProperty(mainResonantFrequency)
        self.mainResonantFrequency.setValue(2500)
        addProperty(firstResonantFrequency)
        self.firstResonantFrequency.setValue(5300)
        addProperty(secondResonantFrequency)
        self.secondResonantFrequency.setValue(6500)
    }
}

AKOrchestra.testForDuration(5)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let note1 = Note()

let phrase = AKPhrase()
phrase.addNote(note1, atTime:1.0)
phrase.addNote(note1, atTime:1.25)
phrase.addNote(note1, atTime:1.5)
phrase.addNote(note1, atTime:2.0)
phrase.addNote(note1, atTime:2.25)
phrase.addNote(note1, atTime:2.5)
phrase.addNote(note1, atTime:3.0)
phrase.addNote(note1, atTime:3.25)
phrase.addNote(note1, atTime:3.5)
phrase.addNote(note1, atTime:3.875)
phrase.addNote(note1, atTime:4.0)

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
