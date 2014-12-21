//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Customized by Nick Arner on 12/21/14.
//
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        let source = AKFMOscillator()
        connect(source)
    
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let line1 = AKLine(firstPoint: 0.ak, secondPoint: 0.08.ak, durationBetweenPoints: 11.ak)
        connect(line1)
        
        let line2 = AKLinearControl(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 11.ak)
        connect(line2)

        let operation = AKFlanger(audioSource: audioSource, delayTime:line1)
        operation.feedback = line2
        connect(operation)
        
        let mix = AKMixedAudio(signal1: audioSource, signal2: operation, balance: 0.5.ak)
        connect(mix)
        
        connect(AKAudioOutput(audioSource:mix))
    }
}

// Set Up
let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)
AKManager.sharedManager().isLogging = true
AKOrchestra.test()
processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")