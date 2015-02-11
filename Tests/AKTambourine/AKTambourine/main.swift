//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 11.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let note = TambourineNote()
        addNoteProperty(note.intensity)
        addNoteProperty(note.dampingFactor)
        addNoteProperty(note.mainResonantFrequency)

        let tambourine = AKTambourine()
        tambourine.intensity = note.intensity
        tambourine.dampingFactor = note.dampingFactor
        tambourine.mainResonantFrequency = note.mainResonantFrequency
        connect(tambourine)

        enableParameterLog(
            "Intensity = ",
            parameter: tambourine.intensity,
            timeInterval:1
        )
        enableParameterLog(
            "Damping Factor = ",
            parameter: tambourine.dampingFactor,
            timeInterval:1
        )
        enableParameterLog(
            "Main Resonant Frequency = ",
            parameter: tambourine.mainResonantFrequency,
            timeInterval:1
        )
        connect(AKAudioOutput(audioSource:tambourine))
    }
}

class TambourineNote: AKNote {
    var intensity = AKNoteProperty()
    var dampingFactor = AKNoteProperty()
    var mainResonantFrequency = AKNoteProperty()

    override init() {
        super.init()
        addProperty(intensity)
        addProperty(dampingFactor)
        addProperty(mainResonantFrequency)
    }

    convenience init(intensity: Int, dampingFactor: Float, mainResonantFrequency: Float) {
        self.init()
        self.intensity.setValue(Float(intensity))
        self.dampingFactor.setValue(dampingFactor)
        self.mainResonantFrequency.setValue(mainResonantFrequency)
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)
let phrase = AKPhrase()

for i in 1...20 {
    let note = TambourineNote(
        intensity: 25+i*20,
        dampingFactor: 1.05-Float(i)/20.0,
        mainResonantFrequency: 1000 + Float(i)
    )
    note.duration.setValue(0.5)
    phrase.addNote(note, atTime: Float(i-1)*0.5)
}

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
