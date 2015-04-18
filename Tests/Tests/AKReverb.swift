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

    var auxilliaryOutput = AKStereoAudio()

    override init() {
        super.init()

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)

        auxilliaryOutput = AKStereoAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:audio)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKStereoAudio) {
        super.init()

        let feedback = AKLine(
            firstPoint:  0.5.ak,
            secondPoint: 1.0.ak,
            durationBetweenPoints: testDuration.ak
        )

        let cutoffFrequency = AKLine(
            firstPoint:    100.ak,
            secondPoint: 10000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let reverb = AKReverb(stereoInput:audioSource)
        reverb.feedback = feedback
        reverb.cutoffFrequency = cutoffFrequency

        enableParameterLog(
            "Feedback = ",
            parameter: feedback,
            timeInterval:0.1
        )

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: cutoffFrequency,
            timeInterval:0.1
        )

        let leftMix = AKMix(
            input1: audioSource.leftOutput,
            input2: reverb.leftOutput,
            balance: 0.5.ak
        )
        let rightMix = AKMix(
            input1: audioSource.rightOutput,
            input2: reverb.rightOutput,
            balance: 0.5.ak
        )
        connect(AKAudioOutput(leftAudio: leftMix, rightAudio: rightMix))

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
