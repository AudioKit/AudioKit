// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPannerTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPanner(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBypass() {
        let engine = AKEngine()
        let input = AKOscillator()
        let pan = AKPanner(input, pan: -1)
        pan.bypass()
        engine.output = pan
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPanLeft() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPanner(input, pan: -1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPanRight() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPanner(input, pan: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
