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

AKOrchestra.testForDuration(10)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
