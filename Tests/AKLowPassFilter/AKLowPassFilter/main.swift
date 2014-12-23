//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/22/14.
//  Customized by Nick Arner on 12/22/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        let source = AKOscillator()
        connect(source)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let halfPower = AKLowFrequencyOscillatingControl()
        halfPower.frequency = 0.5.ak
        connect(halfPower)
        
        let operation = AKLowPassFilter(audioSource: audioSource)
        operation.halfPowerPoint = halfPower.scaledBy(500.ak).plus(500.ak)
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