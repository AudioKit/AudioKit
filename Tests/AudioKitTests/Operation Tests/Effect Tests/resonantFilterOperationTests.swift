// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class ResonantFilterOperationTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        engine.output = OperationEffect(input) { $0.resonantFilter() }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters1() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        engine.output = OperationEffect(input) { $0.resonantFilter(frequency: 200, bandwidth: 40) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        input.start()
        engine.output = OperationEffect(input) { $0.resonantFilter(frequency: 200, bandwidth: 60) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters3() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.resonantFilter(frequency: 220, bandwidth: 40) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
