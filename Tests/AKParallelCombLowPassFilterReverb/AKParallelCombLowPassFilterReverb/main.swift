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
        
        let operation = AKSleighbells()
        
        connect(operation)
        
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:operation)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let operation = AKParallelCombLowPassFilterReverb(input: audioSource)
        
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
instrument.playNote(AKNote(), afterDelay: 0.5)


while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")