//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/808loop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let mixLine = AKLine(
            firstPoint:  0.ak,
            secondPoint: 1.ak,
            durationBetweenPoints: testDuration.ak
        )
        let dishFilename      = "AKSoundFiles.bundle/Sounds/dish.wav"
        let stairwellFilename = "AKSoundFiles.bundle/Sounds/Stairwell.wav"

        let dishConvolution      = AKConvolution(input: audioSource, impulseResponseFilename: dishFilename)
        let stairwellConvolution = AKConvolution(input: audioSource, impulseResponseFilename: stairwellFilename)

        let dishMix      = AKMix(input1: audioSource, input2: dishConvolution,      balance: 0.2.ak)
        let stairwellMix = AKMix(input1: audioSource, input2: stairwellConvolution, balance: 0.2.ak)

        let mix  = AKMix(input1: dishMix, input2: stairwellMix, balance: mixLine)
        setAudioOutput(mix)

        resetParameter(audioSource)

        enableParameterLog(
            "Dish / Stairwell Mix = ",
            parameter: mixLine,
            timeInterval:0.1
        )
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
