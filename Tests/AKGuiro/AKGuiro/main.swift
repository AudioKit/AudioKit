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

        let note = GuiroNote()
        addNoteProperty(note.count)
        addNoteProperty(note.mainResonantFrequency)

        let guiro = AKGuiro()
        guiro.count = note.count
        guiro.mainResonantFrequency = note.mainResonantFrequency
        connect(guiro)

        enableParameterLog(
            "Count = ",
            parameter: guiro.count,
            timeInterval:2
        )

        enableParameterLog(
            "Main Resonant Frequency = ",
            parameter: guiro.mainResonantFrequency,
            timeInterval:2
        )
        connect(AKAudioOutput(audioSource:guiro))
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
        self.count.setValue(Float(count))
        self.mainResonantFrequency.setValue(mainResonantFrequency)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = GuiroNote(count: i*20, mainResonantFrequency: 1000+Float(i)*500)
    note.duration.setValue(1.0)
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
