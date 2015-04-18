//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let oscillator = AKOscillator()
        let pan = AKOscillator()
        pan.frequency = 1.ak

        let panner = AKPanner(input: oscillator)
        panner.pan = pan
        setAudioOutput(panner)

        enableParameterLog(
            "Pan = ",
            parameter: panner.pan,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
