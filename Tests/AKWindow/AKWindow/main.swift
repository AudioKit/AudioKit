//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/27/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()

        let hamming = AKWindow(type: AKWindowTableType.Hamming)
        addFunctionTable(hamming)

        let gaussian = AKWindow(type: AKWindowTableType.Gaussian)
        addFunctionTable(gaussian)

        let kaiser = AKWindow(type: AKWindowTableType.Kaiser)
        addFunctionTable(kaiser)

    }
}

class Note: AKNote {

    override init() {
        super.init()
    }
}

// Set Up
let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
