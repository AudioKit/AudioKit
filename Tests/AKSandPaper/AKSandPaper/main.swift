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

        let note = SandPaperNote()
        addNoteProperty(note.intensity)
        addNoteProperty(note.dampingFactor)

        let sandPaper = AKSandPaper()
        sandPaper.intensity = note.intensity
        sandPaper.dampingFactor = note.dampingFactor
        connect(sandPaper)

        enableParameterLog(
            "Intensity = ",
            parameter: sandPaper.intensity,
            timeInterval:1
        )
        enableParameterLog(
            "Damping Factor = ",
            parameter: sandPaper.dampingFactor,
            timeInterval:1
        )
        connect(AKAudioOutput(audioSource:sandPaper))
    }
}

class SandPaperNote: AKNote {
    var intensity = AKNoteProperty()
    var dampingFactor = AKNoteProperty()

    override init() {
        super.init()
        addProperty(intensity)
        addProperty(dampingFactor)
    }

    convenience init(intensity: Int, dampingFactor: Float) {
        self.init()
        self.intensity.setValue(Float(intensity))
        self.dampingFactor.setValue(dampingFactor)
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)
let phrase = AKPhrase()

for i in 1...10 {
    let note = SandPaperNote(intensity: 40+i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.setValue(1.0)
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
