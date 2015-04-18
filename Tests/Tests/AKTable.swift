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

    override init() {
        super.init()

        let sine     = AKTable.standardSineWave()
        let square   = AKTable.standardSquareWave()
        let triangle = AKTable.standardTriangleWave()
        let sawtooth = AKTable.standardSawtoothWave()
        let htootwas = AKTable.standardReverseSawtoothWave()

        var point: AKParameter

        // Test Table values at specific points
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Sine wave value at 0.25 expect 1 =", parameter: point, timeInterval: 100)
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.5))
        enableParameterLog("Sine wave value at 0.5 expect 0 =", parameter: point, timeInterval: 100)
        point = AKTableValue(table: sine, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Sine wave value at 0.75 expect -1 =", parameter: point, timeInterval: 100)

        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Square wave value at 0.25 expect 1 =", parameter: point, timeInterval: 100)
        point = AKTableValue(table: square, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Square wave value at 0.75 expect -1 =", parameter: point, timeInterval: 100)

        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.25))
        enableParameterLog("Triangle wave value at 0.25 expect 1 =", parameter: point, timeInterval: 100)
        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.5))
        enableParameterLog("Triangle wave value at 0.5 expect 0 =", parameter: point, timeInterval: 100)
        point = AKTableValue(table: triangle, atFractionOfTotalWidth: akp(0.75))
        enableParameterLog("Triangle wave value at 0.75 expect -1 =", parameter: point, timeInterval: 100)

        let lineSegments = AKLineTableGenerator(value: 0.0)
        lineSegments.addValue(1, atIndex: 1)
        lineSegments.appendValue(-1, afterNumberOfElements: 2)
        lineSegments.addValue(0, atIndex: 4)

        let lineTable = AKTable(size: 16384)
        lineTable.populateTableWithGenerator(lineSegments)

        let generator = AKExponentialTableGenerator(value: 0.1)
        generator.addValue(1, atIndex: 1  )
        generator.appendValue(0.1, afterNumberOfElements: 1)
        generator.appendValue(1, afterNumberOfElements: 1)
        generator.addValue(0.1, atIndex: 4)

        let newExponentialTable = AKTable(size: 16384)
        newExponentialTable.populateTableWithGenerator(generator)

        let newArrayTable = AKTable(array: [0, 255])
        let value1 = AKTableValue(table: newArrayTable, atIndex: 0.ak)
        enableParameterLog("expect 0 = ", parameter: value1, timeInterval: 100)
        let value2 = AKTableValue(table: newArrayTable, atIndex: 1.ak)
        enableParameterLog("expect 255 = ", parameter: value2, timeInterval: 100)

        let hamming = AKTable(size: 4096)
        hamming.populateTableWithGenerator(AKWindowTableGenerator.hammingWindow())

        let gaussian = AKTable(size: 4096)
        gaussian.populateTableWithGenerator(AKWindowTableGenerator.gaussianWindow())

        let kaiser = AKTable(size: 4096)
        kaiser.populateTableWithGenerator(AKWindowTableGenerator.kaiserWindow())

        let cosine = AKTable(size: 16384)
        cosine.populateTableWithGenerator(AKHarmonicCosineTableGenerator(numberOfHarmonics: 10, lowestHarmonic: 1, partialMultiplier: 0.7))

        let random = AKTable()
        random.populateTableWithGenerator(AKRandomDistributionTableGenerator.gaussianDistribution())
    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
