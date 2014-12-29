//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let control = AKLowFrequencyOscillator()
        control.type = AKLowFrequencyOscillatorType.SawTooth
        control.amplitude = 100.ak
        control.frequency = 2.ak
        connect(control)


        let operation = AKLowFrequencyOscillator()
        operation.type = AKLowFrequencyOscillatorType.Triangle
        operation.frequency = control.plus(110.ak)
        connect(operation)

        connect(AKAudioOutput(audioSource:operation))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(10)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
