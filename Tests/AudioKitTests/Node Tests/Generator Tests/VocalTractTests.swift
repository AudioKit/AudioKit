// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class VocalTractTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        vocalTract.frequency = 444.5
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNasality() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        vocalTract.nasality = 0.6
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTenseness() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        vocalTract.tenseness = 0.5
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTongueDiameter() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        vocalTract.tongueDiameter = 0.4
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testTonguePosition() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
        vocalTract.tonguePosition = 0.3
        engine.output = vocalTract
        vocalTract.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AudioEngine()
        let vocalTract = VocalTract()
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
        let engine = AudioEngine()
        let vocalTract = VocalTract(frequency: 234.5,
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
