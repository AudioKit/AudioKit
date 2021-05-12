// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class NodeTests: XCTestCase {
    func testNodeBasic() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        XCTAssertNotNil(osc.avAudioNode as? AVAudioUnit)
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
        let osc = Oscillator(waveform: Table(.triangle))
        osc.start()
        let verb = CostelloReverb(osc)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    func testRedundantConnection() {
        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer()
        mixer.addInput(osc)
        mixer.addInput(osc)
        XCTAssertEqual(mixer.connections.count, 1)
    }

    func testDynamicOutput() {
        let engine = AudioEngine()

        let osc1 = Oscillator(waveform: Table(.triangle))
        osc1.start()
        engine.output = osc1

        let audio = engine.startTest(totalDuration: 2.0)

        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let osc2 = Oscillator(waveform: Table(.triangle), frequency: 880)
        osc2.start()
        engine.output = osc2

        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)

        testMD5(audio)
    }

    func testDynamicConnection() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer(osc)

        XCTAssertNil(osc.avAudioNode.engine)

        engine.output = mixer

        // Osc should be attached.
        XCTAssertNotNil(osc.avAudioNode.engine)

        let audio = engine.startTest(totalDuration: 2.0)

        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(waveform: Table(.triangle), frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection2() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer(osc)

        engine.output = mixer
        osc.start()

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(waveform: Table(.triangle), frequency: 880)
        let verb = CostelloReverb(osc2)
        osc2.start()
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection3() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer(osc)
        engine.output = mixer

        osc.start()

        let audio = engine.startTest(totalDuration: 3.0)

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(waveform: Table(.triangle), frequency: 880)
        osc2.start()
        mixer.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection4() {
        let engine = AudioEngine()
        let outputMixer = Mixer()
        let osc = Oscillator(waveform: Table(.triangle))
        outputMixer.addInput(osc)
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 2.0)

        osc.start()

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(waveform: Table(.triangle))
        osc2.frequency = 880

        let localMixer = Mixer()
        localMixer.addInput(osc2)
        outputMixer.addInput(localMixer)

        osc2.start()
        audio.append(engine.render(duration: 1.0))

//        testMD5(audio)
    }

    func testDynamicConnection5() {
        let engine = AudioEngine()
        let outputMixer = Mixer()
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 1.0)

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer()
        mixer.addInput(osc)

        outputMixer.addInput(mixer) // change mixer to osc and this will play

        osc.start()
        audio.append(engine.render(duration: 1.0))

//        testMD5(audio)
    }

    func testDisconnect() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer(osc)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)

        osc.start()

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(osc)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testNodeDetach() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
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

        let osc = Oscillator(waveform: Table(.triangle))
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
        for _ in 0 ..< 16 {
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
        let osc = Oscillator(waveform: Table(.triangle))
        let verb = CostelloReverb(osc)
        let mixer = Mixer(osc, verb)
        engine.output = mixer

        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }

    func testMixerRedundantUpstreamConnection() {
        let engine = AudioEngine()

        let osc = Oscillator(waveform: Table(.triangle))
        let mixer1 = Mixer(osc)
        let mixer2 = Mixer(mixer1)

        engine.output = mixer2

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)

        mixer2.addInput(osc)

        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)
    }

//    func testTransientNodes() {
//        let engine = AudioEngine()
//        let osc = Oscillator(waveform: Table(.triangle))
//        func exampleStart() {
//            let env = AmplitudeEnvelope(osc)
//            osc.amplitude = 1
//            engine.output = env
//            osc.start()
//            try! engine.start()
//            sleep(1)
//        }
//        func exampleStop() {
//            osc.stop()
//            engine.stop()
//            sleep(1)
//        }
//        exampleStart()
//        exampleStop()
//        exampleStart()
//        exampleStop()
//        exampleStart()
//        exampleStop()
//    }

    func testAutomationAfterDelayedConnection() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        let osc2 = Oscillator(waveform: Table(.triangle))
        let mixer = Mixer()
        let events = [AutomationEvent(targetValue: 1320, startTime: 0.0, rampDuration: 0.5)]
        engine.output = mixer
        mixer.addInput(osc)
        let audio = engine.startTest(totalDuration: 2.0)
        osc.play()
        osc.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        mixer.removeInput(osc)
        mixer.addInput(osc2)
        osc2.play()
        osc2.$frequency.automate(events: events)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    // This provides a baseline for measuring the overhead
    // of mixers in testMixerPerformance.
    func testChainPerformance() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        let rev = CostelloReverb(osc)

        XCTAssertNotNil(osc.avAudioNode as? AVAudioUnit)
        XCTAssertNil(osc.avAudioNode.engine)
        osc.start()
        engine.output = rev
        XCTAssertNotNil(osc.avAudioNode.engine)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)

            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()

            audio.append(buf)
        }
    }

    // Measure the overhead of mixers.
    func testMixerPerformance() {
        let engine = AudioEngine()
        let osc = Oscillator(waveform: Table(.triangle))
        let mix1 = Mixer(osc)
        let rev = CostelloReverb(mix1)
        let mix2 = Mixer(rev)

        XCTAssertNotNil(osc.avAudioNode as? AVAudioUnit)
        XCTAssertNil(osc.avAudioNode.engine)
        osc.start()
        engine.output = mix2
        XCTAssertNotNil(osc.avAudioNode.engine)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)

            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()

            audio.append(buf)
        }
    }

    func testConnectionTreeDescriptionForStandaloneNode() {
        let osc = Oscillator(waveform: Table(.triangle))
        XCTAssertEqual(osc.connectionTreeDescription, "\(connectionTreeLinePrefix)↳Oscillator")
    }

    func testConnectionTreeDescriptionForConnectedNode() {
        let osc = Oscillator(waveform: Table(.triangle))
        let verb = CostelloReverb(osc)
        let mixer = Mixer(osc, verb)
        let mixerAddress = MemoryAddress(of: mixer).description

        XCTAssertEqual(mixer.connectionTreeDescription,
        """
        \(connectionTreeLinePrefix)↳Mixer("\(mixerAddress)")
        \(connectionTreeLinePrefix) ↳Oscillator
        \(connectionTreeLinePrefix) ↳CostelloReverb
        \(connectionTreeLinePrefix)  ↳Oscillator
        """)
    }

    #if !os(tvOS)
    func testConnectionTreeDescriptionForNamedNode() {
        let nameString = "Customized Name"
        let sampler = MIDISampler(name: nameString)
        let compressor = Compressor(sampler)
        let mixer = Mixer(compressor)
        let mixerAddress = MemoryAddress(of: mixer).description

        XCTAssertEqual(mixer.connectionTreeDescription,
        """
        \(connectionTreeLinePrefix)↳Mixer("\(mixerAddress)")
        \(connectionTreeLinePrefix) ↳Compressor
        \(connectionTreeLinePrefix)  ↳MIDISampler("\(nameString)")
        """)
    }
    #endif
}
