// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class NodeTests: XCTestCase {

    let osc = Oscillator()

    func testNodeBasic() {
        let engine = AudioEngine()
        let osc = Oscillator()
        XCTAssertNotNil(osc.avAudioUnit)
        XCTAssertNil(osc.avAudioNode.engine)
        osc.start()
        engine.output = osc
        XCTAssertNotNil(osc.avAudioNode.engine)
        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    func testNodeConnection() {
        let engine = AudioEngine()
        let osc = Oscillator()
        osc.start()
        let verb = CostelloReverb(osc)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    func testRedundantConnection() {
        let osc = Oscillator()
        let mixer = Mixer()
        mixer.addInput(osc)
        mixer.addInput(osc)
        XCTAssertEqual(mixer.connections.count, 1)
    }

    func testDynamicOutput() {

        let engine = AudioEngine()

        let osc1 = Oscillator()
        osc1.start()
        engine.output = osc1

        let audio = engine.startTest(totalDuration: 2.0)

        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let osc2 = Oscillator(frequency: 880)
        osc2.start()
        engine.output = osc2

        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)

        testMD5(audio)
        // audition(audio)
    }

    func testDynamicConnection() {

        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer = Mixer(osc)

        XCTAssertNil(osc.avAudioNode.engine)

        engine.output = mixer

        // Osc should be attached.
        XCTAssertNotNil(osc.avAudioNode.engine)

        let audio = engine.startTest(totalDuration: 2.0)

        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection2() {

        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer = Mixer(osc)

        engine.output = mixer
        osc.start()

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(frequency: 880)
        let verb = CostelloReverb(osc2)
        osc2.start()
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
        // audition(audio)
    }

    func testDynamicConnection3() {
        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer = Mixer(osc)
        engine.output = mixer

        osc.start()

        let audio = engine.startTest(totalDuration: 3.0)

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
        // audition(audio)
    }

    func testDisconnect() {

        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer = Mixer(osc)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)

        osc.start()

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
        // audition(audio)
    }

    func testNodeDetach() {
        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer = Mixer(osc)
        engine.output = mixer
        osc.start()

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        osc.detach()

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testTwoEngines() {
        let engine = AudioEngine()
        let engine2 = AudioEngine()

        let osc = Oscillator()
        engine2.output = osc
        osc.start()

        let verb = CostelloReverb(osc)
        engine.output = verb

        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)

    }

    func testManyMixerConnections() {

        let engine = AudioEngine()

        var oscs: [Oscillator] = []
        for _ in 0..<16 {
            oscs.append(Oscillator())
        }

        let mixer = Mixer(oscs)
        engine.output = mixer

        XCTAssertEqual(mixer.avAudioNode.numberOfInputs, 16)

    }

    func connectionCount(node: AVAudioNode) -> Int {
        var count = 0
        for bus in 0 ..< node.numberOfInputs {
            if let inputConnection = node.engine!.inputConnectionPoint(for: node, inputBus: bus) {
                if inputConnection.node != nil {
                    count += 1
                }
            }
        }
        return count
    }

    func testFanout() {

        let engine = AudioEngine()
        let osc = Oscillator()
        let verb = CostelloReverb(osc)
        let mixer = Mixer(osc, verb)
        engine.output = mixer

        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }

    func testMixerRedundantUpstreamConnection() {

        let engine = AudioEngine()

        let osc = Oscillator()
        let mixer1 = Mixer(osc)
        let mixer2 = Mixer(mixer1)

        engine.output = mixer2

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)

        mixer2.addInput(osc)

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)

    }

    func testTransientNodes() {
        let engine = AudioEngine()
        let osc = Oscillator()
        func exampleStart() {
            let env = AmplitudeEnvelope(osc)
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

