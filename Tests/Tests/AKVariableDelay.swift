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

        let delayTime = AKLine(
            firstPoint: 0.ak,
            secondPoint: 0.1.ak,
            durationBetweenPoints: testDuration.ak
        )

        let variableDelay = AKVariableDelay(input: audioSource)
        variableDelay.delayTime = delayTime

        let mix = AKMix(input1: audioSource, input2: variableDelay, balance: 0.5.ak)
        setAudioOutput(mix)

        enableParameterLog(
            "Delay Time = ",
            parameter: variableDelay.delayTime,
            timeInterval:0.1
        )

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
