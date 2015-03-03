//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/2/15.
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
        
        let sine   = AKTable.standardSineWave()
        let square = AKTable.standardSquareWave()
        
        let triangle = AKManager.standardTriangleWave()
        presentFunctionTable(triangle, label: "Standard Triangle Wave")
        
        let sawtooth = AKManager.standardSawtoothWave()
        presentFunctionTable(sawtooth, label: "Standard Sawtooth Wave")
        
        let htootwas = AKManager.standardReverseSawtoothWave()
        presentFunctionTable(htootwas, label: "Standard Reverse Sawtooth Wave")
        
        var point: AKParameter
        
        // Test Table values at specific points
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Sine wave value at 0.25 expect 1 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.5))
        enableParameterLog("Sine wave value at 0.5 expect 0 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Sine wave value at 0.75 expect -1 = ", parameter: point, timeInterval: 100)
        
        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Square wave value at 0.25 expect 1 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Square wave value at 0.75 expect -1 = ", parameter: point, timeInterval: 100)
        
        point = AKTableValue(functionTable: triangle, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Triangle wave value at 0.25 expect 1 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(functionTable: triangle, atFractionOfTotalWidth: akp(0.5))
        enableParameterLog("Triangle wave value at 0.5 expect 0 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(functionTable: triangle, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Triangle wave value at 0.75 expect -1 = ", parameter: point, timeInterval: 100)
        
        let lineSegments = AKLineTable(value: 0.0)
        lineSegments.addValue(1, atIndex: 1)
        lineSegments.appendValue(-1, afterNumberOfElements: 2)
        lineSegments.addValue(0, atIndex: 4)
        lineSegments.size = 8192
        connect(lineSegments)
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

let manager = AKManager.sharedManager()
while(manager.isRunning) {} //do nothing
println("Test complete!")
