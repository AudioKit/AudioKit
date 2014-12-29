//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let sine = AKOscillator()
        connect(sine)

        let position = AKOscillator()
        position.frequency = 0.5.ak
        connect(position)

        let dopplerEffect = AKDopplerEffect(input: sine)
        dopplerEffect.sourcePosition = position.scaledBy(50.ak).plus(100.ak)
        connect(dopplerEffect)
        
        enableParameterLog(
            "Source Position = ",
            parameter: dopplerEffect.sourcePosition,
            frequency:0.1
        )

        connect(AKAudioOutput(audioSource:dopplerEffect))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(5)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
