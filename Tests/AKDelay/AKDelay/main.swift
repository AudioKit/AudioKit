//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/808loop.wav"

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

        let feedbackLine = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 10.ak)
        connect(feedbackLine)

        let operation = AKDelay(input: audioSource, delayTime: 0.1.ak)
        operation.feedback = feedbackLine
        connect(operation)

        let mix = AKMixedAudio(signal1: audioSource, signal2: operation, balance: 0.5.ak)
        connect(mix)

        connect(AKAudioOutput(audioSource:mix))
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
