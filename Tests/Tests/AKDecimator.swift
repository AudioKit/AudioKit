//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        let bitDepth = AKLine(
            firstPoint: 24.ak,
            secondPoint: 18.ak,
            durationBetweenPoints: testDuration.ak
        )

        let sampleRate = AKLine(
            firstPoint: 5000.ak,
            secondPoint: 1000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let decimator = AKDecimator(input: mono)
        decimator.bitDepth = bitDepth
        decimator.sampleRate = sampleRate
        setAudioOutput(decimator)

        enableParameterLog(
            "Bit Depth = ",
            parameter: decimator.bitDepth,
            timeInterval:0.1
        )

        enableParameterLog(
            "Sample Rate = ",
            parameter: decimator.sampleRate,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
