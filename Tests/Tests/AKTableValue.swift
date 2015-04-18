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

    override init() {
        super.init()

        let sine = AKTable.standardSineWave()
        let square = AKTable.standardSquareWave()
        let triangle = AKTable.standardTriangleWave()
        let sawtooth = AKTable.standardSawtoothWave()
        let htootwas = AKTable.standardReverseSawtoothWave()

        var point: AKParameter

        // Test Table values at specific points
        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Square wave value at 0.25 expect 1 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Square wave value at 0.75 expect -1 = ", parameter: point, timeInterval: 100)

        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Triangle wave value at 0.25 expect 1 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.5))
        enableParameterLog("Triangle wave value at 0.5 expect 0 = ", parameter: point, timeInterval: 100)
        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Triangle wave value at 0.75 expect -1 = ", parameter: point, timeInterval: 100)

    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
