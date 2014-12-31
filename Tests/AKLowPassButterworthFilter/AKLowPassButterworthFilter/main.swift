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
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

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

        let cutoffFrequency = AKLine(firstPoint: 1000.ak, secondPoint: 0.ak, durationBetweenPoints: testDuration.ak)
        connect(cutoffFrequency)

        let lowPassButterworthFilter = AKLowPassButterworthFilter(input: audioSource)
        lowPassButterworthFilter.cutoffFrequency = cutoffFrequency
        connect(lowPassButterworthFilter)
        
        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: lowPassButterworthFilter.cutoffFrequency,
            frequency:0.1
        )

        connect(AKAudioOutput(audioSource:lowPassButterworthFilter))
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(testDuration)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
