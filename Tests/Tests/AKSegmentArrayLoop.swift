//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10;

class Instrument : AKInstrument {

    override init() {
        super.init()

        let segmentLoop = AKSegmentArrayLoop(
            frequency: 1.ak,
            initialValue: 440.ak
        )
        segmentLoop.addValue(550.ak, afterDuration: 1.ak, concavity: (-5).ak)
        segmentLoop.addValue(330.ak, afterDuration: 2.ak, concavity: 0.ak)
        segmentLoop.addValue(440.ak, afterDuration: 1.ak, concavity: 5.ak)

        enableParameterLog("segment.floatValue = ", parameter: segmentLoop, timeInterval: 0.1)

        let oscillator = AKOscillator()
        oscillator.frequency = segmentLoop
        setAudioOutput(oscillator)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
