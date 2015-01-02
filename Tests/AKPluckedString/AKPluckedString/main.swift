//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let note = Note()
        addNoteProperty(note.frequency)
        
        let oscil = AKOscillator()
        oscil.frequency = 1.ak
        connect(oscil)
        
        let pluckedString = AKPluckedString(excitationSignal: oscil)
        pluckedString.frequency = note.frequency
        connect(pluckedString)
        
        enableParameterLog(
            "Frequency = ",
            parameter: pluckedString.frequency,
            timeInterval:2
        )
        
        connect(AKAudioOutput(audioSource:pluckedString))
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

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)

let note1 = Note(frequency: 440)
note1.duration.setValue(2.0)
let note2 = Note(frequency: 550)
note2.duration.setValue(2.0)
let note3 = Note(frequency: 660)
note3.duration.setValue(2.0)

let phrase = AKPhrase()
phrase.addNote(note1, atTime:0.5)
phrase.addNote(note2, atTime:1.0)
phrase.addNote(note3, atTime:1.5)
phrase.addNote(note2, atTime:2.0)

instrument.playPhrase(phrase)


while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
