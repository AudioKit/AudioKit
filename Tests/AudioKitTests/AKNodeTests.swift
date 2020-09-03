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
        engine.output = osc
        AKTest()
    }

    func testNodeConnection() {
        osc.start()
        let verb = AKCostelloReverb(osc)
        engine.output = verb
        AKTest()
    }

    func testNodeDeferredConnection() {
        osc.start()
        let verb = AKCostelloReverb()
        osc >>> verb
        engine.output = verb
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

    func testDynamicOutput() {

        duration = 2.0

        let osc1 = AKOscillator()
        osc1.start()
        engine.output = osc1

        AKStartSegmentedTest(duration: 1.0)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        engine.output = osc2

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()

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

    func testDynamicConnection2() {

        duration = 2.0

        let osc = AKOscillator()
        let mixer = AKMixer(osc)

        engine.output = mixer
        osc.start()

        AKStartSegmentedTest(duration: 1.0)

        let osc2 = AKOscillator(frequency: 880)
        let verb = AKCostelloReverb(osc2)
        osc2.start()

        verb >>> mixer

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()
    }

    func testDynamicConnection3() {

        duration = 3.0

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer

        osc.start()

        AKStartSegmentedTest(duration: 1.0)

        let osc2 = AKOscillator(frequency: 880)////////////////////////
        osc2.start()

        osc2 >>> mixer

        AKAppendSegmentedTest(duration: 1.0)

        mixer.disconnect(node: osc2)

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()
    }

    func testDisconnect() {

        duration = 2.0

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        osc.start()
        engine.output = mixer

        AKStartSegmentedTest(duration: 1.0)

        mixer.disconnect(node: osc)

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()

    }

    func testNodeDetach() {

        duration = 2.0

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer
        osc.start()

        AKStartSegmentedTest(duration: 1.0)

        osc.detach()

        AKAppendSegmentedTest(duration: 1.0)

        AKFinishSegmentedTest()

    }

    func testTwoEngines() {

        let engine2 = AKEngine()

        let osc = AKOscillator()
        engine2.output = osc
        osc.start()

        let verb = AKCostelloReverb(osc)
        engine.output = verb

        AKTest()

    }

    func testBadDynamicConnection() {

        let engine = AKEngine()

        let osc = AKOscillator()
        let verb = AKCostelloReverb()

        engine.output = verb

        try! engine.start()

        sleep(1)

        osc >>> verb

        // Ensure connection was not made.
        XCTAssertEqual(verb.connections.count, 0)

    }

}

