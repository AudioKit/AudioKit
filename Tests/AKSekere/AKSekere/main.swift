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

        let note = SekereNote()
        addNoteProperty(note.count)
        addNoteProperty(note.dampingFactor)

        let sekere = AKSekere()
        sekere.count = note.count
        sekere.dampingFactor = note.dampingFactor
        connect(sekere)

        enableParameterLog(
            "Count = ",
            parameter: sekere.count,
            timeInterval:2
        )

        enableParameterLog(
            "Damping Factor = ",
            parameter: sekere.dampingFactor,
            timeInterval:2
        )

        connect(AKAudioOutput(audioSource:sekere .scaledBy(30.ak)))
    }
}

class SekereNote: AKNote {
    var count = AKNoteProperty()
    var dampingFactor = AKNoteProperty()

    override init() {
        super.init()
        addProperty(count)
        addProperty(dampingFactor)
    }

    convenience init(count: Int, dampingFactor: Float) {
        self.init()
        self.count.setValue(Float(count))
        self.dampingFactor.setValue(dampingFactor)
    }
}



let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)

let phrase = AKPhrase()

for i in 1...10 {
    let note = SekereNote(count: i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.setValue(1.0)
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
