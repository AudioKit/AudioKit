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
        let filename = "CsoundLib64.framework/Sounds/808loop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMixedAudio(
            signal1: audio.leftOutput,
            signal2: audio.rightOutput,
            balance: 0.5.ak
        )
        connect(mono)

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
            durationBetweenPoints: testDuration.ak)
        connect(reverbDuration)

        let combFilter = AKCombFilter(input: audioSource)
        combFilter.reverbDuration = reverbDuration
        connect(combFilter)

        enableParameterLog(
            "Reverb Duration = ",
            parameter: combFilter.reverbDuration,
            frequency:0.1
        )

        connect(AKAudioOutput(audioSource:combFilter))
    }
}

// Set Up
let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
