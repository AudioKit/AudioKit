//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let phasor = AKPhasor()
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:phasor)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let resonance = AKLine(
            firstPoint:  0.1.ak,
            secondPoint: 1.0.ak,
            durationBetweenPoints: testDuration.ak
        )

        let cutoffFrequency = AKLine(
            firstPoint: 100.ak,
            secondPoint: 10000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let moogLadder = AKMoogLadder(input: audioSource)
        moogLadder.resonance = resonance
        moogLadder.cutoffFrequency = cutoffFrequency

        setAudioOutput(moogLadder)
        enableParameterLog(
            "Resonance = ",
            parameter: moogLadder.resonance,
            timeInterval:0.2
        )

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: moogLadder.cutoffFrequency,
            timeInterval:0.2
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
