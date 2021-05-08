// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import XCTest
import AudioKit
import CAudioKit

class ClarinetTest: XCTestCase {

    func testClarinet() {
        akSetSeed(0)
        let engine = AudioEngine()
        let clarinet = Clarinet()
        clarinet.trigger(note: 69)
        engine.output = clarinet
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testVelocity() {
        akSetSeed(0)
        let engine = AudioEngine()
        let clarinet = Clarinet()
        clarinet.trigger(note: 69, velocity: 64)
        engine.output = clarinet
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
#endif
