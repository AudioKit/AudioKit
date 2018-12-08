//
//  VocalTractTests.swift
//  iOSTestSuiteTests
//
//  Created by Aurelius Prochazka on 11/26/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class VocalTractTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }


    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.vocalTract()
        }
        AKTestMD5("08151832dac3e5d23d194b4004dc9916")
    }

    func testParameterSweep() {
        output = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: self.duration)
            return AKOperation.vocalTract(frequency: 200 + 200 * line,
                                          tonguePosition: line,
                                          tongueDiameter: line,
                                          tenseness: line,
                                          nasality: line)
        }
        AKTestMD5("73de198b2746be67144e9cd865815f4b")
    }

}
