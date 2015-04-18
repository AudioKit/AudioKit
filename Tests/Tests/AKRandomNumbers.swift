//
//  main.swift
//  AudioKit
//
//  Auto-generated on 12/28/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10
class Instrument : AKInstrument {

    override init() {
        super.init()

        let line = AKLine(firstPoint: 200.ak, secondPoint: 1000.ak, durationBetweenPoints: testDuration.ak)
        let randomWidth = AKRandomNumbers()

        let oscillator = AKOscillator()
        oscillator.frequency = 440.ak.plus(randomWidth.scaledBy(line))
        setAudioOutput(oscillator)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))

