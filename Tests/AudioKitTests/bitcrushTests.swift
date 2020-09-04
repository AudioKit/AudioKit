// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class BitcrushTests: XCTestCase {

    func testBitDepth() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.bitCrush(bitDepth: 7) }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.bitCrush() }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.bitCrush(bitDepth: 7, sampleRate: 4_000) }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSampleRate() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKOperationEffect(input) { $0.bitCrush(sampleRate: 4_000) }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
