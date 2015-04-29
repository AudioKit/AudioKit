//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/1/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let frequencyLine = AKLine(
            firstPoint:   10.ak,
            secondPoint: 880.ak,
            durationBetweenPoints: testDuration.ak
        )

        let carrierMultiplierLine = AKLine(
            firstPoint:  2.ak,
            secondPoint: 0.ak,
            durationBetweenPoints: testDuration.ak
        )

        let modulatingMultiplierLine = AKLine(
            firstPoint:  0.ak,
            secondPoint: 2.ak,
            durationBetweenPoints: testDuration.ak
        )

        let indexLine = AKLine(
            firstPoint:   0.ak,
            secondPoint: 30.ak,
            durationBetweenPoints: testDuration.ak
        )

        let fmOscillator = AKFMOscillator()
        fmOscillator.baseFrequency = frequencyLine
        fmOscillator.carrierMultiplier = carrierMultiplierLine
        fmOscillator.modulatingMultiplier = modulatingMultiplierLine
        fmOscillator.modulationIndex = indexLine

        enableParameterLog(
            "Base Frequency = ",
            parameter: fmOscillator.baseFrequency,
            timeInterval:0.1
        )

        enableParameterLog(
            "Carrier Multiplier = ",
            parameter: fmOscillator.carrierMultiplier,
            timeInterval:0.1
        )

        enableParameterLog(
            "Modulating Multiplier = ",
            parameter: fmOscillator.modulatingMultiplier,
            timeInterval:0.1
        )

        enableParameterLog(
            "Modulation Index = ",
            parameter: fmOscillator.modulationIndex,
            timeInterval:0.1
        )

        setAudioOutput(fmOscillator)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
