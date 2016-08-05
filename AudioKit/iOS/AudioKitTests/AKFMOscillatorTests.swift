//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKFMOscillatorTests: AKTestCase {
    
    var duration = 0.1
    
    func testFMOscillator() {
        let fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
        AudioKit.testOutput(fm, duration: duration)
        let expectedMD5 = "362f9f2f10f025ec8c798713e2bf6a2e"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5)
    }
    
    func testFMOscillatorSquareWave() {
        let fm = AKFMOscillator(waveform: AKTable(.Square, size: 4096))
        AudioKit.testOutput(fm, duration: duration)
        let expectedMD5 = "c6b194d7bf925ade38c3a1d5333326f8"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5)
    }
}
