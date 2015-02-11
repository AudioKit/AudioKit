//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    override init() {
        super.init()
        let lineSegments = AKLineSegments(value: 0.0)
        lineSegments.addValue(1, atIndex: 1)
        lineSegments.appendValue(-1, afterNumberOfElements: 2)
        lineSegments.addValue(0, atIndex: 4)
        lineSegments.size = 8192
        addFunctionTable(lineSegments)

        let exponentialCurves = AKExponentialCurves(value: 0.1)
        exponentialCurves.addValue(1, atIndex: 1  )
        exponentialCurves.appendValue(0.1, afterNumberOfElements: 1)
        exponentialCurves.appendValue(1, afterNumberOfElements: 1)
        exponentialCurves.addValue(0.1, atIndex: 4)
        exponentialCurves.size = 16384
        addFunctionTable(exponentialCurves)
    }

}

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)
AKManager.sharedManager().isLogging = true
AKOrchestra.testForDuration(10)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
