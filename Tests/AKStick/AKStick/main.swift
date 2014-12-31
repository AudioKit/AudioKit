//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 2.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let operation = AKStick()
        operation.intensity = 10.ak
        operation.dampingFactor = 0.9.ak
        operation.amplitude = 2.ak
        connect(operation)
        connect(AKAudioOutput(audioSource:operation))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
