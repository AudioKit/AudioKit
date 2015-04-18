//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "AKSoundFiles.bundle/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        let mono = AKMix(monoAudioFromStereoInput: audio);
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let fundamentalFrequencyLine = AKLine(
            firstPoint: 0.ak,
            secondPoint: 1000.ak,
            durationBetweenPoints: testDuration.ak
        )

        enableParameterLog(
            "Fundamental Frequency = ",
            parameter: fundamentalFrequencyLine,
            timeInterval:0.1
        )

        let stringResonator = AKStringResonator(input: audioSource)
        stringResonator.fundamentalFrequency = fundamentalFrequencyLine

        setAudioOutput(stringResonator)

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
