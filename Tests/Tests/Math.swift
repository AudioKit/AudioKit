//
//  main.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

let testDuration: Float = 1

class Instrument : AKInstrument {

    override init() {
        super.init()

        let first = 3.ak
        let second = 0.14.ak

        let sum        = first.plus(second)
        let difference = first.minus(second)
        let product    = first.scaledBy(second)
        let quotient   = first.dividedBy(second)
        let inverse    = first.inverse()
        let floor      = first.floor()
        let round      = difference.round()
        let fraction   = sum.fractionalPart()
        let absolute   = first.minus(quotient).absoluteValue()
        let log        = first.log()
        let log10      = first.log10()
        let squareRoot = first.squareRoot()

        let control = AKOscillator()
        control.frequency = 0.3.ak
        control.amplitude = 7.ak
        connect(control)

        let oscillator = AKOscillator()
        oscillator.frequency = control.plus(14.ak).floor().scaledBy(100.ak).plus(220.ak)
        oscillator.amplitude = control.fractionalPart()
        setAudioOutput(oscillator.scaledBy(0.5.ak))


        enableParameterLog("Sum        expected  3.140000 = ", parameter: sum,        timeInterval: 10)
        enableParameterLog("Difference expected  2.860000 = ", parameter: difference, timeInterval: 10)
        enableParameterLog("Product    expected  0.420000 = ", parameter: product,    timeInterval: 10)
        enableParameterLog("Quotient   expected 21.428571 = ", parameter: quotient,   timeInterval: 10)
        enableParameterLog("Inverse    expected  0.333333 = ", parameter: inverse,    timeInterval: 10)
        enableParameterLog("Floor      expected  3.000000 = ", parameter: floor,      timeInterval: 10)
        enableParameterLog("Round      expected  3.000000 = ", parameter: round,      timeInterval: 10)
        enableParameterLog("Fraction   expected  0.140000 = ", parameter: fraction,   timeInterval: 10)
        enableParameterLog("Absolute   expected 18.428571 = ", parameter: absolute,   timeInterval: 10)
        enableParameterLog("Log        expected  1.098612 = ", parameter: log,        timeInterval: 10)
        enableParameterLog("Log10      expected  0.477121 = ", parameter: log10,      timeInterval: 10)
        enableParameterLog("SquareRoot expected  1.732051 = ", parameter: squareRoot, timeInterval: 10)

    }
}

AKOrchestra.testForDuration(testDuration)

let instrument = Instrument()
AKOrchestra.addInstrument(instrument)

instrument.play()

NSThread.sleepForTimeInterval(NSTimeInterval(testDuration))
