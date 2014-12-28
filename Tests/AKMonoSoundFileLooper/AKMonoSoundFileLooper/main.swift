//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = Note()
        addNoteProperty(note.frequencyRatio)
        addNoteProperty(note.amplitude)
        addNoteProperty(note.playLoopMode)

        let operation = AKMonoSoundFileLooper(        soundFile: requiredValue
)
        operation.frequencyRatio = note.frequencyRatio
        operation.amplitude = note.amplitude
        operation.playLoopMode = note.playLoopMode
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
    }
}

class Note: AKNote {
    var frequencyRatio = AKNoteProperty()
    var amplitude = AKNoteProperty()
    var playLoopMode = AKNoteProperty()

    override init() {
        super.init()
        addProperty(frequencyRatio)
        self.frequencyRatio.setValue(1)
        addProperty(amplitude)
        self.amplitude.setValue(1)
        addProperty(playLoopMode)
        self.playLoopMode.setValue(AKSoundFileLooperModeNormalLooping)
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

let note1 = Note()
// specify properties and create more notes here

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
// add more phrase notes here

instrument.playPhrase(phrase)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
