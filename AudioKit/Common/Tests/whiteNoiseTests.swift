//
//  whiteNoiseTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class WhiteNoiseTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.whiteNoise()
        }
        AKTestMD5("3383b3631de1e37d309c4e35ff023c1b")
    }

    func testAmplitude() {
        output = AKOperationGenerator { _ in
            return AKOperation.whiteNoise(amplitude: 0.456)
        }
        AKTestMD5("1c052b4e036810c10a6f6fae633daa91")
    }

    func testParameterSweep() {
        output = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: self.duration)
            return AKOperation.whiteNoise(amplitude: line)
        }
        AKTestMD5("d5713a02d87070053570eeb6a75f3283")
    }

}
