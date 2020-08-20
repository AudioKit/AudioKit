// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
@testable import AudioKit

class AKOperationTests: XCTestCase {

    func testDelay() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let delay = operation.delay(time: 1.2, feedback: 0.8)
        XCTAssertEqual(delay.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.2 delay "#)
    }

    func testSineWave() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        XCTAssertEqual(operation.sporth, "1.1 2.2 sine ")
    }

    func testSmoothDelay() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let delay = operation.smoothDelay(time: 1.1, feedback: 0.8, samples: 256, maximumDelayTime: 1.9)
        XCTAssertEqual(delay.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 256.0 smoothdelay "#)
    }

    func testVariableDelay() {
        let operation = AKOperation.sineWave(frequency: 1.1, amplitude: 2.2)
        let delay = operation.variableDelay(time: 1.1, feedback: 0.8, maximumDelayTime: 1.9)
        XCTAssertEqual(delay.sporth, #""ak" "0" gen_vals 1.1 2.2 sine 0 "ak" tset 0 "ak" tget 0.8 1.1 1.9 vdelay "#)
    }
}
