// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKDiodeClipperTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDiodeClipper(input)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters1() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDiodeClipper(input, cutoffFrequency: 1000, gain: 1.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters2() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDiodeClipper(input, cutoffFrequency: 2000, gain: 2.0)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
