//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10

class Instrument : AKInstrument {

    override init() {
        super.init()

        let pinkBalanceLine = AKLine(
            firstPoint:  0.ak,
            secondPoint: 1.ak,
            durationBetweenPoints: testDuration.ak
        )

        enableParameterLog(
            "Pink Balance = ",
            parameter: pinkBalanceLine,
            timeInterval:0.5
        )

        let betaLine = AKLine(
            firstPoint:(-0.99).ak,
            secondPoint: 0.99.ak,
            durationBetweenPoints: testDuration.ak
        )

        enableParameterLog(
            "Beta = ",
            parameter: betaLine,
            timeInterval:0.5
        )

        let noise = AKNoise()
        noise.pinkBalance = pinkBalanceLine
        noise.beta = betaLine
        setAudioOutput(noise)
    }
}
AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
