// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKDynamicRangeCompressorTests: XCTestCase {

    func testAttackDuration() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input, ratio: 0.5, attackDuration: 0.2)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input,
                                          ratio: 0.5,
                                          threshold: -1,
                                          attackDuration: 0.2,
                                          releaseDuration: 0.2)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRatio() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input, ratio: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testReleaseDuration() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input, ratio: 0.5, releaseDuration: 0.2)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testThreshold() {
        let engine = AKEngine()
        let input = AKOscillator(amplitude: 2.0)
        engine.output = AKDynamicRangeCompressor(input, ratio: 0.5, threshold: -1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
