//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/26/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKFMOscillator()
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
