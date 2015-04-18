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

        let phasor = AKPhasor()
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:phasor)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let distortion = AKLine(firstPoint: 0.1.ak, secondPoint: 0.9.ak, durationBetweenPoints: testDuration.ak)

        let cutoffFrequency = AKLine(firstPoint: 300.ak, secondPoint: 3000.ak, durationBetweenPoints: testDuration.ak)

        let resonance = AKLine(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: testDuration.ak)

        let threePoleLowpassFilter = AKThreePoleLowpassFilter(input: audioSource)
        threePoleLowpassFilter.distortion = distortion
        threePoleLowpassFilter.cutoffFrequency = cutoffFrequency
        threePoleLowpassFilter.resonance = resonance
        setAudioOutput(threePoleLowpassFilter)

        enableParameterLog(
            "Distortion = ",
            parameter: threePoleLowpassFilter.distortion,
            timeInterval:0.1
        )

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: threePoleLowpassFilter.cutoffFrequency,
            timeInterval:0.1
        )

        enableParameterLog(
            "Resonance = ",
            parameter: threePoleLowpassFilter.resonance,
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
