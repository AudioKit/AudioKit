//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Nick Arner on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let jitter = AKJitter()
        jitter.amplitude = 3000.ak

        let sine = AKOscillator()
        sine.frequency = jitter

        enableParameterLog(
            "Jitter = ",
            parameter: jitter,
            timeInterval:0.1
        )
        setAudioOutput(sine)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
