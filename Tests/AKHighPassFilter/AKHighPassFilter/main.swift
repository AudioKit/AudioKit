//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 11.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMix(input1: audio.leftOutput, input2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let cutoffFrequency = AKLine(
            firstPoint: 1.ak,
            secondPoint: 4000.ak,
            durationBetweenPoints: testDuration.ak)
        connect(cutoffFrequency)

        let highPassFilter = AKHighPassFilter(input: audioSource)
        highPassFilter.cutoffFrequency = cutoffFrequency
        connect(highPassFilter)

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: highPassFilter.cutoffFrequency,
            timeInterval:0.1
        )

        connect(AKAudioOutput(audioSource:highPassFilter))

        resetParameter(audioSource)
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
