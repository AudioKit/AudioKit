//
//  InstrumentTests.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest

class InstrumentTests: AKTestCase {
    
    func testFMOscillator() {
        testInstrument = TestFMOscillator()
        process()
        XCTAssertEqual(calculatedMD5(), "2f03be95c90706a303370c38907f069f")
    }
    
    func testMix() {
        testInstrument = TestMix()
        process()
        XCTAssertEqual(calculatedMD5(), "5220de22421c1ceb97d91f1772654974")
    }

    func testOscillator() {
        testInstrument = TestOscillator()
        process()
        XCTAssertEqual(calculatedMD5(), "b08efaa81dbf543493074d2464d7dcda")
    }
}
