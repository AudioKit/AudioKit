// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import XCTest
import AVFoundation
import CAudioKit

class AKNodeTests: AKTestCase {

    let osc = AKOscillator()

    func testNodeBasic() {
        duration = 0.1
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()
        output = osc
        AKTest()
    }

    func testNodeConnection() {
        osc.start()
        let verb = AKCostelloReverb(osc)
        output = verb
        AKTest()
    }

    func testNodeDeferredConnection() {
        osc.start()
        let verb = AKCostelloReverb()
        osc >>> verb
        output = verb
        AKTest()
    }

    func testBadConnection() {

        let osc1 = AKOscillator()
        let osc2 = AKOscillator()

        osc1 >>> osc2

        XCTAssertEqual(osc2.connections.count, 0)
    }

    func testRedundantConnection() {
        let osc = AKOscillator()
        let mixer = AKMixer()
        osc >>> mixer
        osc >>> mixer
        XCTAssertEqual(mixer.connections.count, 1)
    }

    func testDynamicConnection() {

        duration = 2.0
        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer

        osc.start()

        AKStartSegmentedTest(duration: 1.0)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        osc2 >>> mixer

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()
    }

}

class AKNodeDynamicConnectionTests: XCTestCase {


    func testDynamicConnection2() {

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        let verb = AKCostelloReverb(osc2)
        osc2.start()

        verb >>> mixer

        sleep(1)

        engine.stop()
    }

    func testTwoEngines() {

        let engine1 = AKEngine()
        let engine2 = AKEngine()

        let osc = AKOscillator()
        engine1.output = osc
        osc.start()

        let verb = AKCostelloReverb(osc)
        engine2.output = verb

    }

    func testDisconnect() {

        let engine = AKEngine()
        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        osc.start()
        engine.output = mixer
        try! engine.start()

        sleep(1)

        mixer.disconnect(node: osc)

        print("disconnected")
        sleep(1)
        print("done")

        engine.stop()

    }

    func testDynamicConnection3() {

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        let engine = AKEngine()
        engine.output = mixer

        osc.start()
        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()

        osc2 >>> mixer

        sleep(1)

        mixer.disconnect(node: osc2)

        sleep(1)

        engine.stop()
    }


    func testNodeDetach() {

        let engine = AKEngine()

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer
        osc.start()
        try! engine.start()
        sleep(1)

        osc.detach()
        sleep(1)

        engine.stop()

    }

    func testDynamicOutput() {

        let engine = AKEngine()

        let osc1 = AKOscillator()
        osc1.start()
        engine.output = osc1

        try! engine.start()

        sleep(1)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        engine.output = osc2

        sleep(1)

        engine.stop()

    }


}
