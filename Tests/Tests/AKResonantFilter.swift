//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let source = AKFMOscillator()
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let centerFrequency = AKLine(
            firstPoint:   220.ak,
            secondPoint: 3000.ak,
            durationBetweenPoints: testDuration.ak
        )

        let bandwidth = AKLine(
            firstPoint:   10.ak,
            secondPoint: 100.ak,
            durationBetweenPoints: testDuration.ak
        )

        let resonantFilter = AKResonantFilter(input: audioSource)
        resonantFilter.centerFrequency = centerFrequency
        resonantFilter.bandwidth = bandwidth

        let balance = AKBalance(input: resonantFilter, comparatorAudioSource: audioSource)
        setAudioOutput(balance)

        enableParameterLog(
            "Center Frequency = ",
            parameter: resonantFilter.centerFrequency,
            timeInterval:0.2
        )

        enableParameterLog(
            "Bandwidth = ",
            parameter: resonantFilter.bandwidth,
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
