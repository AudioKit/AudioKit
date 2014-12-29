//
//  main.swift
//  AudioKit
//
//  Created by Nick Arner and Aurelius Prochazka on 12/26/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let bambooSticks = AKBambooSticks()
        connect(bambooSticks)

        connect(AKAudioOutput(audioSource:bambooSticks))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

AKOrchestra.testForDuration(2)

instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
