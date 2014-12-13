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

        let operation = AKMarimba()
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

// Set Up
AKManager.sharedManager().fullPathToAudioKit = "/Users/aure/Developer/AudioKit/"
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.test()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
