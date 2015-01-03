//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let source = AKStick()
        connect(source)

        let beatenPlate = AKBeatenPlate(input: source.scaledBy(10.ak))

        connect(beatenPlate)
        connect(AKAudioOutput(audioSource:beatenPlate))
    }
}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKOrchestra.testForDuration(1)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
