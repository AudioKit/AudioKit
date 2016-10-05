//
//  variableDelayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class variableDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: self.duration)
            return input.variableDelay(time: 0.1 * ramp, feedback: 0.9 * ramp)
        }
        AKTestMD5("e22477485213822ea56e2fa6a4d5fe86")
    }

}
