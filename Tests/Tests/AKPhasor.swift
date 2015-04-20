//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let phasingControl = AKPhasor()
        phasingControl.frequency = 5.ak

        let phasor = AKPhasor()
        phasor.frequency = phasingControl.scaledBy(880.ak)
        setAudioOutput(phasor)

        enableParameterLog(
            "Frequency = ",
            parameter: phasor.frequency,
            timeInterval:0.1
        )
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
