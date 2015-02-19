//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/27/14.
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

        let mono = AKMix(input1: audio.leftOutput, input2: audio.rightOutput, balance: 0.5.ak)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let feedbackLine = AKLine(
            firstPoint: 0.ak,
            secondPoint: 1.ak,
            durationBetweenPoints: testDuration.ak
        )

        let delay = AKDelay(input: audioSource, delayTime: 0.1.ak)
        delay.feedback = feedbackLine
        connect(delay)

        enableParameterLog(
            "Feedback = ",
            parameter: delay.feedback,
            timeInterval:0.1
        )

        let mix = AKMix(input1: audioSource, input2: delay, balance: 0.5.ak)

        setAudioOutput(mix)

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

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
