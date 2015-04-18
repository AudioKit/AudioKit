//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let oscillatingControl = AKOscillator()
        oscillatingControl.frequency = 2.ak

        let oscillator = AKOscillator()
        oscillator.frequency = oscillatingControl.scaledBy(110.ak).plus(440.ak)
        setAudioOutput(oscillator)

        enableParameterLog(
            "Frequency = ",
            parameter: oscillator.frequency,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
