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

    var vocalTract = AKOperationGenerator { _ in return AKOperation.vocalTract() }

    override func setUp() {
        afterStart = { self.vocalTract.start() }
        duration = 1.0
    }

    func testDefault() {
        output = vocalTract
        AKTestMD5("08151832dac3e5d23d194b4004dc9916")
    }

    func testParameterSweep() {
        vocalTract = AKOperationGenerator { _ in
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
        output = vocalTract
        AKTestMD5("73de198b2746be67144e9cd865815f4b")
    }

}
