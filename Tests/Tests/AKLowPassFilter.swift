//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()

        let source = AKOscillator()
        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:source)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let halfPower = AKLowFrequencyOscillator()
        halfPower.frequency = 0.5.ak

        let lowPassFilter = AKLowPassFilter(audioSource: audioSource)
        lowPassFilter.halfPowerPoint = halfPower.scaledBy(500.ak).plus(500.ak)

        enableParameterLog(
            "Cutoff Frequency = ",
            parameter: lowPassFilter.halfPowerPoint,
            timeInterval:0.1
        )

        setAudioOutput(lowPassFilter)

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
