//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/28/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    func presentFunctionTable(functionTable:AKFunctionTable, label:String) {
        NSLog("\n\n%@", label)
        addFunctionTable(functionTable)
    }
    
    override init() {
        super.init()
        let sine = AKManager.standardSineWave()
        presentFunctionTable(sine, label: "Standard Sine Wave")
        
        let square = AKManager.standardSquareWave()
        presentFunctionTable(square, label: "Standard Square Wave")
        
        let triangle = AKManager.standardTriangleWave()
        presentFunctionTable(triangle, label: "Standard Triangle Wave")
        
        let sawtooth = AKManager.standardSawtoothWave()
        presentFunctionTable(sawtooth, label: "Standard Sawtooth Wave")
        
        let htootwas = AKManager.standardReverseSawtoothWave()
        presentFunctionTable(htootwas, label: "Standard Reverse Sawtooth Wave")
        
        let lineTable = AKLineTable(value: 0.0)
        lineTable.addValue(1, atIndex: 1)
        lineTable.appendValue(-1, afterNumberOfElements: 2)
        lineTable.addValue(0, atIndex: 8)
        lineTable.addValue(1, atIndex: 7)
        lineTable.size = 8192
        addFunctionTable(lineTable)
    }

}

AKOrchestra.testForDuration(5)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
