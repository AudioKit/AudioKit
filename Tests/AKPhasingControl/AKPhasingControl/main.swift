//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
                
        let operation = AKPhasingControl()
        connect(operation)
        
        let source = AKPhasor()
        source.frequency = operation.scaledBy(3000.ak)
        
        connect(source)
        
        connect(AKAudioOutput(audioSource:source))
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.test()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
