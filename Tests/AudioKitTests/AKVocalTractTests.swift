// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKVocalTractTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.frequency = 444.5
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNasality() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.nasality = 0.6
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTenseness() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.tenseness = 0.5
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTongueDiameter() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.tongueDiameter = 0.4
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTonguePosition() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.tonguePosition = 0.3
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract()
        vocalTract.frequency = 234.5
        vocalTract.tonguePosition = 0.3
        vocalTract.tongueDiameter = 0.4
        vocalTract.tenseness = 0.5
        vocalTract.nasality = 0.6
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetOnInit() {
        let engine = AKEngine()
        let vocalTract = AKVocalTract(frequency: 234.5,
                                      tonguePosition: 0.3,
                                      tongueDiameter: 0.4,
                                      tenseness: 0.5,
                                      nasality: 0.6)
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
