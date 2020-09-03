// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class AKNodeTests: XCTestCase {

    let osc = AKOscillator()

    func testNodeBasic() {
        let engine = AKEngine()
        let osc = AKOscillator()
        XCTAssertNotNil(osc.avAudioUnit)
        osc.start()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    func testNodeConnection() {
        let engine = AKEngine()
        let osc = AKOscillator()
        osc.start()
        let verb = AKCostelloReverb(osc)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    func testRedundantConnection() {
        let osc = AKOscillator()
        let mixer = AKMixer()
        mixer.addInput(osc)
        mixer.addInput(osc)
        XCTAssertEqual(mixer.connections.count, 1)
    }

    func testDynamicOutput() {

        let engine = AKEngine()

        let audio = engine.startTest(totalDuration: 2.0)
        let osc1 = AKOscillator()
        osc1.start()
        engine.output = osc1

        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        engine.output = osc2

        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)

        testMD5(audio)
    }

    func testDynamicConnection() {

        let engine = AKEngine()
        let audio = engine.startTest(totalDuration: 2.0)

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer

        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection2() {

        let engine = AKEngine()
        let audio = engine.startTest(totalDuration: 2.0)

        let osc = AKOscillator()
        let mixer = AKMixer(osc)

        engine.output = mixer
        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = AKOscillator(frequency: 880)
        let verb = AKCostelloReverb(osc2)
        osc2.start()
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection3() {
        let engine = AKEngine()
        let audio = engine.startTest(totalDuration: 3.0)

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer

        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = AKOscillator(frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
        audition(audio)
    }

    func testDisconnect() {

        let engine = AKEngine()
        let audio = engine.startTest(totalDuration: 2.0)

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer

        osc.start()

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)

    }

    func testNodeDetach() {
        let engine = AKEngine()
        let audio = engine.startTest(totalDuration: 2.0)

        let osc = AKOscillator()
        let mixer = AKMixer(osc)
        engine.output = mixer
        osc.start()

        audio.append(engine.render(duration: 1.0))

        osc.detach()

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)

    }

    func testTwoEngines() {
        let engine = AKEngine()
        let engine2 = AKEngine()

        let osc = AKOscillator()
        engine2.output = osc
        osc.start()

        let verb = AKCostelloReverb(osc)
        engine.output = verb

        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)

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

    func testTransientNodes() {
        let engine = AKEngine()
        let osc = AKOscillator()
        func exampleStart() {
            let env = AKAmplitudeEnvelope(osc)
            osc.amplitude = 1
            engine.output = env
            osc.start()
            try! engine.start()
            sleep(1)
        }
        func exampleStop() {
            osc.stop()
            engine.stop()
            sleep(1)
        }
        exampleStart()
        exampleStop()
        exampleStart()
        exampleStop()
        exampleStart()
        exampleStop()
    }

}

