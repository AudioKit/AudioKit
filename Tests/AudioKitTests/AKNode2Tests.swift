// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import XCTest
import AVFoundation

class AKNode2Tests: AKTestCase2 {

    let osc = AKOscillator2()

    func testNode2Basic() {
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()
        output = osc
        AKTest()
    }

    func testNode2Connection() {
        osc.start()
        let verb = AKCostelloReverb(osc)
        output = verb
        AKTest()
    }

    func testNode2DeferredConnection() {
        osc.start()
        let verb = AKCostelloReverb()
        osc >>> verb
        output = verb
        AKTest()
    }
}
