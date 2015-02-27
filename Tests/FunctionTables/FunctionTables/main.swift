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
        
        presentFunctionTable(AKManager.standardSineWave(),            label: "Standard Sine Wave")
        presentFunctionTable(AKManager.standardSquareWave(),          label: "Standard Square Wave")
        presentFunctionTable(AKManager.standardTriangleWave(),        label: "Standard Triangle Wave")
        presentFunctionTable(AKManager.standardSawtoothWave(),        label: "Standard Sawtooth Wave")
        presentFunctionTable(AKManager.standardReverseSawtoothWave(), label: "Standard Reverse Sawtooth Wave")

    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
