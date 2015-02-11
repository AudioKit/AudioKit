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
        connect(frequencyLine)

        let frequencyLineDeviation = AKOscillator()
        frequencyLineDeviation.frequency = 1.ak
        frequencyLineDeviation.amplitude = 30.ak
        connect(frequencyLineDeviation)

        let toneGenerator = AKOscillator()
        toneGenerator.frequency = frequencyLine.plus(frequencyLineDeviation)
        connect(toneGenerator)

        let output = AKAudioOutput(audioSource: toneGenerator)
        connect(output)

        let tracker = AKTrackedFrequency(
            audioSource: toneGenerator,
            sampleSize: 512.ak
        )
        connect(tracker)

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


// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(testDuration)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
