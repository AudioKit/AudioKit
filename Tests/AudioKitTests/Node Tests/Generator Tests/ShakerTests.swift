// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import XCTest
import AudioKit
import CAudioKit

class ShakerTests: XCTestCase {

    func testShaker() {
        let engine = AudioEngine()

        akSetSeed(0)

        let shaker = Shaker()
        shaker.trigger(type: .maraca)
        engine.output = shaker

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testShakerType() {
        let engine = AudioEngine()

        akSetSeed(0)

        let shaker = Shaker()
        shaker.trigger(type: .tunedBambooChimes)
        engine.output = shaker

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testShakerAmplitude() {
        let engine = AudioEngine()

        akSetSeed(0)

        let shaker = Shaker()
        shaker.trigger(type: .tunedBambooChimes, amplitude: 1.0)
        engine.output = shaker

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
#endif
