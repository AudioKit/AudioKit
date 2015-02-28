//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 10



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
        
        let midpoint = AKTableValue(functionTable: sawtooth, atIndex: akp(0.5))
        enableParameterLog("Middle point: ", parameter: midpoint, timeInterval: 100)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
