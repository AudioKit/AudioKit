//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Customized by Nick Arner on 12/26/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        let operation = AKPhasor()
        connect(operation)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:operation)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let distortion = AKLinearControl(firstPoint: 0.1.ak, secondPoint: 0.9.ak, durationBetweenPoints: 11.ak)
        connect(distortion)
        
        let cutoffFrequency = AKLinearControl(firstPoint: 300.ak, secondPoint: 3000.ak, durationBetweenPoints: 11.ak)
        connect(cutoffFrequency)

        let resonance = AKLinearControl(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 11.ak)
        connect(resonance)

        let operation = AKThreePoleLowpassFilter(input: audioSource)
        operation.distortion = distortion
        operation.cutoffFrequency = cutoffFrequency
        operation.resonance = resonance
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
AKOrchestra.test()
processor.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")