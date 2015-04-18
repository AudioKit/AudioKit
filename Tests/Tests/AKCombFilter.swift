//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 20.0

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

        let reverbDuration = AKLine(
            firstPoint: 0.ak,
            secondPoint: 3.ak,
            durationBetweenPoints: testDuration.ak
        )

        let combFilter = AKCombFilter(input: audioSource)
        combFilter.reverbDuration = reverbDuration

        enableParameterLog(
            "Reverb Duration = ",
            parameter: combFilter.reverbDuration,
            timeInterval:0.1
        )
        setAudioOutput(combFilter)

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
