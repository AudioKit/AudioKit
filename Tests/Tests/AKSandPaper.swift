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
        let sandPaper = AKSandPaper()
        sandPaper.intensity = note.intensity
        sandPaper.dampingFactor = note.dampingFactor
        setAudioOutput(sandPaper)

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
        self.intensity.value = Float(intensity)
        self.dampingFactor.value = dampingFactor
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let phrase = AKPhrase()

for i in 1...10 {
    let note = SandPaperNote(intensity: 40+i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.value = 1.0
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
