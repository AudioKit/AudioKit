//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let control = AKLowFrequencyOscillator()
        control.waveformType = AKLowFrequencyOscillator.waveformTypeForSawtooth()
        control.amplitude = 100.ak
        control.frequency = 2.ak

        let lowFrequencyOscillator = AKLowFrequencyOscillator()
        lowFrequencyOscillator.waveformType = AKLowFrequencyOscillator.waveformTypeForTriangle()
        lowFrequencyOscillator.frequency = control.plus(110.ak)

        enableParameterLog(
            "Frequency = ",
            parameter: lowFrequencyOscillator.frequency,
            timeInterval:0.1
        )

        setAudioOutput(lowFrequencyOscillator)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
