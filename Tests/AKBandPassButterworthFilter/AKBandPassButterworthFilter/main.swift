//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/20/14.
//  Customized by Nick Arner on 12/20/14.
//
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        let operation = AKSleighbells()
        connect(operation)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:operation)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let line = AKLinearControl(firstPoint: 10000.ak, secondPoint: 500.ak, durationBetweenPoints: 11.ak)
        connect(line)

        let line2 = AKLinearControl(firstPoint: 25.ak, secondPoint: 10000.ak, durationBetweenPoints: 11.ak)
        connect(line2)

        let operation = AKBandPassButterworthFilter(audioSource: audioSource)
        operation.centerFrequency = line
        operation.bandwidth = line2
        connect(operation)
        
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

processor.play()
let note1 = AKNote()
// specify properties and create more notes here

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

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
