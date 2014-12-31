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
        let note = CabasaNote()
        addNoteProperty(note.count)
        addNoteProperty(note.dampingFactor)
        
        let cabasa = AKCabasa()
        cabasa.count = note.count
        cabasa.dampingFactor = note.dampingFactor
        connect(cabasa)
        
        enableParameterLog(
            "Count = ",
            parameter: cabasa.count,
            frequency:2
        )
        
        enableParameterLog(
            "Damping Factor = ",
            parameter: cabasa.dampingFactor,
            frequency:2
        )
        
        connect(AKAudioOutput(audioSource:cabasa))
    }
}

class CabasaNote: AKNote {
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
    let note = CabasaNote(count: i*20, dampingFactor: 1.1-Float(i)/10.0)
    note.duration.setValue(1.0)
    phrase.addNote(note, atTime: Float(i-1))
}

instrument.playPhrase(phrase)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
