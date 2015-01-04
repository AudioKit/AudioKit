//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMixedAudio(signal1: audio.leftOutput, signal2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let frequencyLine = AKLine(firstPoint: 200.ak, secondPoint: 2500.ak, durationBetweenPoints: testDuration.ak)
        connect(frequencyLine)

        let bandWidthLine = AKLine(firstPoint: 1.ak, secondPoint: 100.ak, durationBetweenPoints: testDuration.ak)
        connect(bandWidthLine)

        let equalizerFilter = AKEqualizerFilter(input: audioSource)
        equalizerFilter.centerFrequency = frequencyLine
        equalizerFilter.bandwidth = bandWidthLine
        equalizerFilter.gain = 100.ak
        connect(equalizerFilter)

        enableParameterLog(
            "Center Frequency = ",
            parameter: equalizerFilter.centerFrequency,
            timeInterval:0.1
        )

        enableParameterLog(
            "Bandwidth = ",
            parameter: equalizerFilter.bandwidth,
            timeInterval:1.0
        )

        let output = AKBalance(input: equalizerFilter, comparatorAudioSource: audioSource)
        connect(output)

        connect(AKAudioOutput(audioSource:output))

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

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
