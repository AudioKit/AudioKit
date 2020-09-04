// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKHighPassButterworthFilterTests: XCTestCase {

    func testCutoffFrequency() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKHighPassButterworthFilter(input, cutoffFrequency: 400)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKHighPassButterworthFilter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
