//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let oscillator = AKFMOscillator()
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:oscillator)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let cutoffFrequency = AKLine(firstPoint: 220.ak, secondPoint: 3000.ak, durationBetweenPoints: testDuration.ak)
        let bandwidth = AKLine(firstPoint: 10.ak, secondPoint: 100.ak, durationBetweenPoints: testDuration.ak)

        let variableFrequencyResponseBandPassFilter = AKVariableFrequencyResponseBandPassFilter(input: audioSource)
        variableFrequencyResponseBandPassFilter.cutoffFrequency = cutoffFrequency
        variableFrequencyResponseBandPassFilter.bandwidth = bandwidth
        variableFrequencyResponseBandPassFilter.scalingFactor = AKVariableFrequencyResponseBandPassFilter.scalingFactorPeak()

        let balance = AKBalance(input: variableFrequencyResponseBandPassFilter, comparatorAudioSource: audioSource)
        setAudioOutput(balance)

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: variableFrequencyResponseBandPassFilter.cutoffFrequency,
            timeInterval:0.1
        )

        enableParameterLog(
            "Bandwidth = ",
            parameter: variableFrequencyResponseBandPassFilter.bandwidth,
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
