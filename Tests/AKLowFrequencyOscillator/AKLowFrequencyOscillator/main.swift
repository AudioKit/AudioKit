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
        control.type = AKLowFrequencyOscillatorType.SawTooth
        control.amplitude = 100.ak
        control.frequency = 2.ak
        connect(control)


        let lowFrequencyOscillator = AKLowFrequencyOscillator()
        lowFrequencyOscillator.type = AKLowFrequencyOscillatorType.Triangle
        lowFrequencyOscillator.frequency = control.plus(110.ak)
        connect(lowFrequencyOscillator)
        
        enableParameterLog(
            "Frequency = ",
            parameter: lowFrequencyOscillator.frequency,
            frequency:0.1
        )

        connect(AKAudioOutput(audioSource:lowFrequencyOscillator))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(testDuration)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
