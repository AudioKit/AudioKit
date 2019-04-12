//
//  variableDelayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class VariableDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: self.duration)
            return input.variableDelay(time: 0.1 * ramp, feedback: 0.9 * ramp)
        }
        AKTestMD5("8403729b6af476b361c20004d5ee6df2")
    }

}
