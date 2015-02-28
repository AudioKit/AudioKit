//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {
    
    override init() {
        super.init()
        
        let exponentialTable = AKExponentialTable(value: 0.1)
        exponentialTable.addValue(1, atIndex: 1  )
        exponentialTable.appendValue(0.1, afterNumberOfElements: 1)
        exponentialTable.appendValue(1, afterNumberOfElements: 1)
        exponentialTable.addValue(0.1, atIndex: 4)
        exponentialTable.size = 16384
        addFunctionTable(exponentialTable)
    }
    
}

AKOrchestra.testForDuration(5)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
