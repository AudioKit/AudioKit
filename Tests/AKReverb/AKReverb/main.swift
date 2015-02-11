//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Nick Arner on 12/24/14.
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

        let mono = AKMix(input1: audio.leftOutput, input2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}
class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let feedback = AKLine(firstPoint: 0.5.ak, secondPoint: 0.9.ak, durationBetweenPoints: testDuration.ak)
        connect(feedback)

        let cutoffFrequency = AKLine(firstPoint: 100.ak, secondPoint: 10000.ak, durationBetweenPoints: testDuration.ak)
        connect(cutoffFrequency)

        let reverb = AKReverb(input:audioSource)
        reverb.feedback = feedback
        reverb.cutoffFrequency = cutoffFrequency
        connect(reverb)

        enableParameterLog(
            "Feedback = ",
            parameter: reverb.feedback,
            timeInterval:0.1
        )

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: reverb.cutoffFrequency,
            timeInterval:0.1
        )

        let leftMix = AKMix(input1: audioSource, input2: reverb.leftOutput, balance: 0.5.ak)
        connect(leftMix)

        let rightMix = AKMix(input1: audioSource, input2: reverb.rightOutput, balance: 0.5.ak)
        connect(rightMix)

        connect(AKAudioOutput(leftAudio: leftMix, rightAudio: rightMix))

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
