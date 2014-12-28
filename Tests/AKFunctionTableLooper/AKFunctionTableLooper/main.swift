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
        addNoteProperty(note.startTime)
        addNoteProperty(note.endTime)
        addNoteProperty(note.transpositionRatio)
        addNoteProperty(note.amplitude)
        addNoteProperty(note.crossfadeDuration)
        addNoteProperty(note.loopMode)

        let operation = AKFunctionTableLooper(        functionTable: requiredValue
)
        operation.startTime = note.startTime
        operation.endTime = note.endTime
        operation.transpositionRatio = note.transpositionRatio
        operation.amplitude = note.amplitude
        operation.crossfadeDuration = note.crossfadeDuration
        operation.loopMode = note.loopMode
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
    }
}

class Note: AKNote {
    var startTime = AKNoteProperty()
    var endTime = AKNoteProperty()
    var transpositionRatio = AKNoteProperty()
    var amplitude = AKNoteProperty()
    var crossfadeDuration = AKNoteProperty()
    var loopMode = AKNoteProperty()

    override init() {
        super.init()
        addProperty(startTime)
        self.startTime.setValue(0)
        addProperty(endTime)
        self.endTime.setValue(0)
        addProperty(transpositionRatio)
        self.transpositionRatio.setValue(1)
        addProperty(amplitude)
        self.amplitude.setValue(1)
        addProperty(crossfadeDuration)
        self.crossfadeDuration.setValue(0)
        addProperty(loopMode)
        self.loopMode.setValue(AKFunctionTableLooperModeForward)
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
