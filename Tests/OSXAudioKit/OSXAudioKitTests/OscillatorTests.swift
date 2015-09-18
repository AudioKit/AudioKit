//
//  OscillatorTests.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest

class OscillatorTests: AKTestCase {
    
    func testOscillator() {
        testInstrument = Oscillator()
        process(2)
        AKTestAssertMD5("b08efaa81dbf543493074d2464d7dcda")
        printMD5()
    }
    
    func testFMOscillator() {
        testInstrument = FMOscillator()
        process(2)
        AKTestAssertMD5("2f03be95c90706a303370c38907f069f")
        printMD5()
    }
}
