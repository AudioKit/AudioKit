//
//  main.swift
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Customized by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKVibes()
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
AKManager.sharedAKManager().fullPathToAudioKit = "/Users/aure/Developer/h4y/AudioKit/"
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.test()

while(AKManager.sharedAKManager().isRunning) {} //do nothing
println("Test complete!")
