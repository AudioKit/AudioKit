//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: NSTimeInterval = 10.0

class Instrument : AKInstrument {

    override init() {
        super.init()

        let sine = AKOscillator()
        let position = AKOscillator()
        position.frequency = 0.5.ak

        let dopplerEffect = AKDopplerEffect(input: sine)
        dopplerEffect.sourcePosition = position.scaledBy(50.ak).plus(100.ak)

        enableParameterLog(
            "Source Position = ",
            parameter: dopplerEffect.sourcePosition,
            timeInterval:0.1
        )
        setAudioOutput(dopplerEffect)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
