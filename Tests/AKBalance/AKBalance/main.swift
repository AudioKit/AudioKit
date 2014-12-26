//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Customized by Nick Arner on 12/21/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    var auxilliaryOutput = AKAudio()
    
    override init() {
        super.init()
        
        let amplitude = AKOscillatingControl()
        connect(amplitude)
        
        let oscillator = AKOscillator()
        oscillator.amplitude = amplitude
        connect(oscillator)
        
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:oscillator)
    }
}

class Processor : AKInstrument {
    
    init(audioSource: AKAudio) {
        super.init()
        
        let synth = AKFMOscillator()
        connect(synth)
        
        let operation = AKBalance(input: synth, comparatorAudioSource: audioSource)
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