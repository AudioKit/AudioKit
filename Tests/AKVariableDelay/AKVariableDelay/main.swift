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
        let filename = "CsoundLib64.framework/Sounds/808loop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMixedAudio(
            signal1: audio.leftOutput,
            signal2: audio.rightOutput,
            balance: testDuration.ak)
        connect(mono)

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
        connect(delayTime)

        let variableDelay = AKVariableDelay(input: audioSource)
        variableDelay.delayTime = delayTime
        connect(variableDelay)

        let mix = AKMixedAudio(signal1: audioSource, signal2: variableDelay, balance: 0.5.ak)
        connect(mix)

        enableParameterLog(
            "Delay Time = ",
            parameter: variableDelay.delayTime,
            timeInterval:0.1
        )

        connect(AKAudioOutput(audioSource:mix))

        resetParameter(audioSource)
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(10)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
