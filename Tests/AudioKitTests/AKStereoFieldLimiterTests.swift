// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKStereoFieldLimiterTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHalf() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput, amount: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNone() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput, amount: 0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
