//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10

class Instrument : AKInstrument {

    override init() {
        super.init()

        let amplitudeLineDeviation = AKOscillator()
        amplitudeLineDeviation.frequency = 0.1.ak
        amplitudeLineDeviation.amplitude = 0.5.ak

        let toneGenerator = AKOscillator()
        toneGenerator.amplitude = amplitudeLineDeviation.plus(akp(0.5))
        setAudioOutput(toneGenerator)

        let tracker = AKTrackedAmplitude(
            input: toneGenerator
        )

        enableParameterLog(
            "Actual amplitude =  ",
            parameter: toneGenerator.amplitude,
            timeInterval: 0.1
        )

        enableParameterLog(
            "Tracked amplitude = ",
            parameter: tracker,
            timeInterval: 0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
