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
        
        let source = AKFMOscillator()
        connect(source)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let centerFrequency = AKLinearControl(firstPoint: 220.ak, secondPoint: 3000.ak, durationBetweenPoints: 11.ak)
        connect(centerFrequency)
        
        let bandwidth = AKLinearControl(firstPoint: 10.ak, secondPoint: 100.ak, durationBetweenPoints: 11.ak)
        connect(bandwidth)
        
        let operation = AKResonantFilter(audioSource: audioSource)
        operation.centerFrequency = centerFrequency
        operation.bandwidth = bandwidth
        connect(operation)
        
        let balance = AKBalance(input: operation, comparatorAudioSource: audioSource)
        connect(balance)
        
        connect(AKAudioOutput(audioSource:balance))
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