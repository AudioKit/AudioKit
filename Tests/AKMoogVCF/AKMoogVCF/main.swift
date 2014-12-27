//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Customized by Nick Arner on 12/19/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"
        
        let audio = AKFileInput(filename: filename)
        connect(audio)
        
        let mono = AKMixedAudio(signal1: audio.leftOutput, signal2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}


class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let cutoffFrequency = AKLine(firstPoint: 200.ak, secondPoint: 6000.ak, durationBetweenPoints: 11.ak)
        connect(cutoffFrequency)
        
        let operation = AKMoogVCF(input: audioSource)
        operation.cutoffFrequency = cutoffFrequency
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
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
