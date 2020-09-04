// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import CAudioKit

class AKClarinetTest: XCTestCase {

    func testClarinet() {
        akSetSeed(0)
        let engine = AKEngine()
        let clarinet = AKClarinet()
        clarinet.trigger(note: 69)
        engine.output = clarinet
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testVelocity() {
        akSetSeed(0)
        let engine = AKEngine()
        let clarinet = AKClarinet()
        clarinet.trigger(note: 69, velocity: 64)
        engine.output = clarinet
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
