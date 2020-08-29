// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import XCTest
import AVFoundation

class AKNode2Tests: XCTestCase {

    func testNode2Basic() {

        let engine = AKEngine()

        let osc = AKOscillator2()
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()

        engine.output = osc

        do {
            try engine.start()
        } catch let error {
            XCTFail("Couldn't start engine: \(error)")
        }

        sleep(2)

        engine.stop()

    }

    func testNode2Connection() {

        let engine = AKEngine()

        let osc = AKOscillator2()
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()

        let verb = AKCostelloReverb2(osc)

        engine.output = verb

        do {
            try engine.start()
        } catch let error {
            XCTFail("Couldn't start engine: \(error)")
        }

        sleep(2)

        osc.stop()

        sleep(2)

        engine.stop()

    }
}
