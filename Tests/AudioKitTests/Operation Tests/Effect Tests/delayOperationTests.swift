// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DelayOperationTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.delay() }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testFeedback() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.delay(feedback: 0.99) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.delay(time: 0.01, feedback: 0.99) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testTime() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.delay(time: 0.01) }
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

}
