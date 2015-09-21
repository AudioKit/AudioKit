//
//  InstrumentTests.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest

class InstrumentTests: AKTestCase {
    

    
    func testMix() {
        testInstrument = AKMixTester()
        process()
        XCTAssertEqual(calculatedMD5(), "5220de22421c1ceb97d91f1772654974")
    }

    func testOscillator() {
        testInstrument = AKOscillatorTester()
        process()
        XCTAssertEqual(calculatedMD5(), "b08efaa81dbf543493074d2464d7dcda")
    }
    
    func testPhasor() {
        testInstrument = AKPhasorTester()
        process()
        XCTAssertEqual(calculatedMD5(), "5966be0858b60866826b685f31acb395")
    }
    
    func testSilence() {
        testInstrument = SilenceTester()
        process()
        XCTAssertEqual(calculatedMD5(), "83d625897761e70d8eb580426a2724f1")
    }
    
    func testTrackedAmplitude() {
        testInstrument = AKTrackedAmplitudeTester()
        process()
        XCTAssertEqual(calculatedMD5(), "3f0f17b839b354522f8a2f66bfe45d35")
    }
}
