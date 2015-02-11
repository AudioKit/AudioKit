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

        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMix(input1: audio.leftOutput, input2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        let bitDepth = AKLine(
            firstPoint: 24.ak,
            secondPoint: 18.ak,
            durationBetweenPoints: testDuration.ak)
        connect(bitDepth)

        let sampleRate = AKLine(
            firstPoint: 5000.ak,
            secondPoint: 1000.ak,
            durationBetweenPoints: testDuration.ak)
        connect(sampleRate)

        let decimator = AKDecimator(input: mono)
        decimator.bitDepth = bitDepth
        decimator.sampleRate = sampleRate
        connect(decimator)

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

        connect(AKAudioOutput(audioSource:decimator))
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
