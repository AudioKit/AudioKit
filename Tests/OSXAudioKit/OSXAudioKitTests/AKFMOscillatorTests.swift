//
//  AKFMOscillatorTests.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/20/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import XCTest

class AKFMOscillatorTests: AKTestCase {
    
    func testFMOscillator() {
        testInstrument = AKFMOscillatorTester()
        process()
        XCTAssertEqual(calculatedMD5(), "2f03be95c90706a303370c38907f069f")
    }
    
    func testPresetStunRay() {
        testInstrument = AKPresetTester(AKFMOscillator.presetStunRay())
        process()
        XCTAssertEqual(calculatedMD5(), "063238e644742d147c39a47429e5aad5")
    }
    
    func testPresetWobble() {
        testInstrument = AKPresetTester(AKFMOscillator.presetWobble())
        process()
        XCTAssertEqual(calculatedMD5(), "1e358ca1683057525cc06e9918f5d173")
    }
}
