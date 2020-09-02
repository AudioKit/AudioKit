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

    func testRedundantConnection() {
        let osc = AKOscillator()
        let mixer = AKMixer()
        mixer.addInput(osc)
        mixer.addInput(osc)
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
        mixer.addInput(osc2)

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
        mixer.addInput(verb)

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

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        AKAppendSegmentedTest(duration: 1.0)

        mixer.removeInput(osc2)

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

        mixer.removeInput(osc)

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

    func testManyMixerConnections() {

        let engine = AKEngine()
        var oscs: [AKOscillator] = []
        for _ in 0..<16 {
            oscs.append(AKOscillator())
        }

        let mixer = AKMixer(oscs)
        engine.output = mixer

        XCTAssertEqual(mixer.avAudioNode.numberOfInputs, 16)

    }

    func connectionCount(node: AVAudioNode) -> Int {
        var count = 0
        for bus in 0 ..< node.numberOfInputs {
            if let cp = node.engine!.inputConnectionPoint(for: node, inputBus: bus) {
                if cp.node != nil {
                    count += 1
                }
            }
        }
        return count
    }

    func testFanout() {

        let engine = AKEngine()
        let osc = AKOscillator()
        let verb = AKCostelloReverb(osc)
        let mixer = AKMixer(osc, verb)
        engine.output = mixer

        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }

    func testMixerRedundantUpstreamConnection() {

        let engine = AKEngine()

        let osc = AKOscillator()
        let mixer1 = AKMixer(osc)
        let mixer2 = AKMixer(mixer1)

        engine.output = mixer2

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)

        mixer2.addInput(osc)

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)

    }

}

