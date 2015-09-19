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
        testInstrument = AKFMOscillatorTester()
        process()
        XCTAssertEqual(calculatedMD5(), "2f03be95c90706a303370c38907f069f")
    }
    
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
    
    func testSilence() {
        testInstrument = SilenceTester()
        process()
        XCTAssertEqual(calculatedMD5(), "6160230370c1f7ca3dc2ced3cd39f3dd")
    }
    
    func testTrackedAmplitude() {
        testInstrument = AKTrackedAmplitudeTester()
        process()
        XCTAssertEqual(calculatedMD5(), "3f0f17b839b354522f8a2f66bfe45d35")
    }
}
