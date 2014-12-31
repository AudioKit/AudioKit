//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 2.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let crunch = AKCrunch()
        connect(crunch)
        connect(AKAudioOutput(audioSource:crunch))
        
        enableParameterLog(
            "Count = ",
            parameter: crunch.intensity,
            frequency:1
        )
        enableParameterLog(
            "Damping Factor = ",
            parameter: crunch.dampingFactor,
            frequency:1
        )
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(testDuration)
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
