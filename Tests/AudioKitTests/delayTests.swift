// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DelayTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.delay() }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testFeedback() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.delay(feedback: 0.99) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.delay(time: 0.01, feedback: 0.99) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testTime() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.delay(time: 0.01) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

}
