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

class AKNode2DynamicConnectionTests: XCTestCase {

    func testDynamicConnection() {

        let osc = AKOscillator2()
        let mixer = AKMixer2(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator2(frequency: 880)
        osc2.start()

        osc2 >>> mixer

        sleep(1)

        engine.stop()
    }

    func testDynamicConnection2() {

        let osc = AKOscillator2()
        let mixer = AKMixer2(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator2(frequency: 880)
        let verb = AKCostelloReverb(osc2)
        osc2.start()

        verb >>> mixer

        sleep(1)

        engine.stop()
    }
}
