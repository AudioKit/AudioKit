// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class ResonantFilterTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        input.start()
        engine.output = AKOperationEffect(input) { $0.resonantFilter() }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters1() {
        let engine = AKEngine()
        let input = AKOscillator()
        input.start()
        engine.output = AKOperationEffect(input) { $0.resonantFilter(frequency: 200, bandwidth: 40) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AKEngine()
        let input = AKOscillator()
        input.start()
        engine.output = AKOperationEffect(input) { $0.resonantFilter(frequency: 200, bandwidth: 60) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters3() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.resonantFilter(frequency: 220, bandwidth: 40) }
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
