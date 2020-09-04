// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKToneComplementFilterTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKToneComplementFilter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHalfPowerPoint() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKToneComplementFilter(input, halfPowerPoint: 500)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
