//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let frequencyLine = AKLine(
            firstPoint:   200.ak,
            secondPoint: 2500.ak,
            durationBetweenPoints: testDuration.ak
        )

        let bandWidthLine = AKLine(
            firstPoint:    1.ak,
            secondPoint: 100.ak,
            durationBetweenPoints: testDuration.ak
        )

        let equalizerFilter = AKEqualizerFilter(input: audioSource)
        equalizerFilter.centerFrequency = frequencyLine
        equalizerFilter.bandwidth = bandWidthLine
        equalizerFilter.gain = 100.ak

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
        setAudioOutput(output)

        resetParameter(audioSource)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

processor.play()
instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
