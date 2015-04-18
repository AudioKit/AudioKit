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

        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"
        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio)

        auxilliaryOutput = AKAudio.globalParameter()
        appendOutput(auxilliaryOutput, withInput: mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let delayTime = AKLine(
            firstPoint:  0.0.ak,
            secondPoint: 0.1.ak,
            durationBetweenPoints: testDuration.ak
        )

        let feedback = AKLine(
            firstPoint:  0.ak,
            secondPoint: 1.ak,
            durationBetweenPoints: testDuration.ak
        )

        let flanger = AKFlanger(input: audioSource, delayTime:delayTime)
        flanger.feedback = feedback

        let mix = AKMix(input1: audioSource, input2: flanger, balance: 0.5.ak)

        enableParameterLog(
            "Feedback = ",
            parameter: flanger.feedback,
            timeInterval:0.1
        )

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

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
