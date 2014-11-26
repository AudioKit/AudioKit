//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/22/14.
//  Modified by Aurelius Prochazka on 11/23/14 to include sine table.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKFMOscillator()
        
        operation.setOptionalCarrierMultiplier(4.4.ak)
        operation.carrierMultiplier = 2.4.ak
        operation.carrierMultiplier.value()
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
let orchestra = AKOrchestra()
let instrument = Instrument()
orchestra.addInstrument(instrument)
let manager = AKManager.sharedAKManager()

// Run Test
manager.runTestOrchestra(orchestra)
while(manager.isRunning) {} //do nothing
println("Test complete!")
