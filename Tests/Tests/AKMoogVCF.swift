//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/19/14.
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

        let cutoffFrequency = AKLine(
            firstPoint: 200.ak,
            secondPoint: 6000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let moogVCF = AKMoogVCF(input: audioSource)
        moogVCF.cutoffFrequency = cutoffFrequency
        setAudioOutput(moogVCF)

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: moogVCF.cutoffFrequency,
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
