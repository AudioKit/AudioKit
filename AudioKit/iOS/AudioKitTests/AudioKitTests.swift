//
//  AudioKitTests.swift
//  AudioKitTests
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKTestCase: XCTestCase {

    var duration = 1.0

    override func setUp() {
        super.setUp()
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        AudioKit.stop()
        super.tearDown()
    }

    func testFMOscillator() {
        let samples = Int(duration * AKSettings.sampleRate * 2.0) // Doubling for stereo

        let fm = AKFMOscillator(waveform: AKTable(.Sine, size: 4096))
        AudioKit.testOutput(fm, samples: samples)
        AudioKit.start()
        fm.start()

        while AudioKit.tester!.isStarted { usleep(10) }

        let expectedMD5 = "1b8e1a3b9ed6d9da25f2e87d6c53849b"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5, "Expected \(expectedMD5) but got \(md5)")
    }

    func testFMOscillatorSquareWave() {
        let samples = Int(duration * AKSettings.sampleRate * 2.0) // Doubling for stereo

        let fm = AKFMOscillator(waveform: AKTable(.Square, size: 4096))
        AudioKit.testOutput(fm, samples: samples)
        AudioKit.start()
        fm.start()

        while AudioKit.tester!.isStarted { usleep(10) }

        let expectedMD5 = "8bd2d4b2db6e7060627da6fd33f7b4b0"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5, "Expected \(expectedMD5) but got \(md5)")
    }


}
