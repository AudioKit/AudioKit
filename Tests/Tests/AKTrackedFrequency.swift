//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10

class Instrument : AKInstrument {

    override init() {
        super.init()

        let frequencyLine = AKLine(
            firstPoint: 110.ak,
            secondPoint: 880.ak,
            durationBetweenPoints: testDuration.ak
        )

        let frequencyLineDeviation = AKOscillator()
        frequencyLineDeviation.frequency = 1.ak
        frequencyLineDeviation.amplitude = 30.ak

        let toneGenerator = AKOscillator()
        toneGenerator.frequency = frequencyLine.plus(frequencyLineDeviation)
        setAudioOutput(toneGenerator)

        let tracker = AKTrackedFrequency(
            audioSource: toneGenerator,
            sampleSize: 512.ak
        )

        enableParameterLog(
            "Actual frequency =  ",
            parameter: toneGenerator.frequency,
            timeInterval: 0.1
        )

        enableParameterLog(
            "Tracked frequency = ",
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
