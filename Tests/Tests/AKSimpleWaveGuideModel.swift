//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 11.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)
        let simpleWaveGuideModel = AKSimpleWaveGuideModel(input: mono)

        let cutoffLine = AKLine(firstPoint: 1000.ak, secondPoint: 5000.ak, durationBetweenPoints: testDuration.ak)

        let frequencyLine = AKLine(firstPoint: 12.ak, secondPoint: 1000.ak, durationBetweenPoints: testDuration.ak)

        let feedbackLine = AKLine(firstPoint: 0.ak, secondPoint: 0.8.ak, durationBetweenPoints: testDuration.ak)

        simpleWaveGuideModel.cutoff = cutoffLine
        simpleWaveGuideModel.frequency = frequencyLine
        simpleWaveGuideModel.feedback = feedbackLine
        setAudioOutput(simpleWaveGuideModel)

        enableParameterLog(
            "Cutoff = ",
            parameter: simpleWaveGuideModel.cutoff,
            timeInterval:0.1
        )

        enableParameterLog(
            "Frequency = ",
            parameter: simpleWaveGuideModel.frequency,
            timeInterval:0.1
        )

        enableParameterLog(
            "Feedback = ",
            parameter: simpleWaveGuideModel.feedback,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
