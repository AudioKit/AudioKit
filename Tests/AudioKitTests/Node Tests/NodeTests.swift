// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeTests: XCTestCase {
    func testNodeBasic() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 0.1)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    #if os(macOS) // For some reason failing on iOS and tvOS
    func testNodeConnection() {
        let engine = Engine()
        let sampler = Sampler()
        let verb = Reverb(sampler)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 0.1))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }
    #endif

    func testNodeOutputFormatRespected() {
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 2)!
        let engine = AudioEngine()
        let sampler = Sampler()
        let verb = CustomFormatReverb(sampler, outputFormat: outputFormat)
        engine.output = verb

        XCTAssertEqual(engine.mainMixerNode!.avAudioNode.inputFormat(forBus: 0), outputFormat)
        XCTAssertEqual(verb.avAudioNode.inputFormat(forBus: 0), Settings.audioFormat)
    }
    
    func testRedundantConnection() {
        let player = Sampler()
        let mixer = Mixer()
        mixer.addInput(player)
        mixer.addInput(player)
        XCTAssertEqual(mixer.connections.count, 1)
    }
    
    func testDynamicOutput() {
        let engine = Engine()

        let sampler1 = Sampler()
        engine.output = sampler1
        
        let audio = engine.startTest(totalDuration: 2.0)
        sampler1.play(url: URL.testAudio)
        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let sampler2 = Sampler()
        engine.output = sampler2
        sampler2.play(url: URL.testAudioDrums)
        
        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)
        
        testMD5(audio)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testDynamicConnection() {
        let engine = Engine()
        
        let osc1 = PlaygroundOscillator(waveform: Table(.triangle), frequency: 440, amplitude: 0.1)
        let mixer = Mixer(osc1)
        
        XCTAssertNil(osc1.avAudioNode.engine)
        
        engine.output = mixer
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        osc1.play()
        
        audio.append(engine.render(duration: 1.0))
        
        let osc2 = PlaygroundOscillator(waveform: Table(.triangle), frequency: 880, amplitude: 0.1)
        mixer.addInput(osc2)
        osc2.play()
        audio.append(engine.render(duration: 1.0))
        
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }

    func testDynamicConnection2() throws {
        try XCTSkipIf(true, "TODO Skipped test")

        let engine = Engine()

        let sampler1 = Sampler()
        let mixer = Mixer(sampler1)

        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)
        sampler1.play(url: URL.testAudio)

        audio.append(engine.render(duration: 1.0))

        let sampler2 = Sampler()
        let verb = Reverb(sampler2)
        sampler2.play(url: URL.testAudioDrums)
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }

    func testDynamicConnection3() throws {
        try XCTSkipIf(true, "TODO Skipped test")

        let engine = Engine()

        let sampler1 = Sampler()
        let mixer = Mixer(sampler1)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 3.0)
        sampler1.play(url: URL.testAudio)
        
        audio.append(engine.render(duration: 1.0))

        let sampler2 = Sampler()
        mixer.addInput(sampler2)

        sampler2.play(url: URL.testAudioDrums)

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(sampler2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection4() throws {
        try XCTSkipIf(true, "TODO Skipped test")
        let engine = Engine()
        let outputMixer = Mixer()
        let player1 = Sampler()
        outputMixer.addInput(player1)
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 2.0)

        player1.play(url: URL.testAudio)
        
        audio.append(engine.render(duration: 1.0))

        let player2 = Sampler()

        let localMixer = Mixer()
        localMixer.addInput(player2)
        outputMixer.addInput(localMixer)

        player2.play(url: URL.testAudioDrums)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection5() throws {
        try XCTSkipIf(true, "TODO Skipped test")
        let engine = Engine()
        let outputMixer = Mixer()
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 1.0)

        let player = Sampler()
        
        let mixer = Mixer()
        mixer.addInput(player)

        outputMixer.addInput(mixer) // change mixer to osc and this will play

        player.play(url: URL.testAudio)
        
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDisconnect() {
        let engine = Engine()

        let player = Sampler()
        
        let mixer = Mixer(player)
        engine.output = mixer
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        player.play(url: URL.testAudio)
        
        audio.append(engine.render(duration: 1.0))
        
        mixer.removeInput(player)
        
        audio.append(engine.render(duration: 1.0))
        
        testMD5(audio)
    }
    
//    func testNodeDetach() {
//        let engine = AudioEngine()
//
//        let player = Sampler()
//
//        let mixer = Mixer(player)
//        engine.output = mixer
//
//        let audio = engine.startTest(totalDuration: 2.0)
//
//        player.play(url: URL.testAudio)
//
//        audio.append(engine.render(duration: 1.0))
//
//        player.detach()
//
//        audio.append(engine.render(duration: 1.0))
//
//        testMD5(audio)
//    }

    func testTwoEngines() {
        let engine = AudioEngine()
        let engine2 = AudioEngine()
        
        let sampler = Sampler()
        
        engine2.output = sampler
        
        let verb = Reverb(sampler)
        engine.output = verb
        
        let audio = engine.startTest(totalDuration: 0.1)
        sampler.play(url: URL.testAudio)
        
        audio.append(engine.render(duration: 0.1))
        XCTAssert(audio.isSilent)
    }
    
//    func testManyMixerConnections() {
//        let engine = AudioEngine()
//        
//        var samplers: [Sampler] = []
//        for _ in 0 ..< 16 {
//            samplers.append(Sampler())
//        }
//        
//        let mixer = Mixer(samplers)
//        engine.output = mixer
//        
//        XCTAssertEqual(mixer.avAudioNode.inputCount, 16)
//    }
    
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
        let player = Sampler()
        
        let verb = Reverb(player)
        let mixer = Mixer(player, verb)
        engine.output = mixer
        
        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }
    
    func testMixerRedundantUpstreamConnection() {
        let engine = AudioEngine()

        let player = Sampler()
        
        let mixer1 = Mixer(player)
        let mixer2 = Mixer(mixer1)
        
        engine.output = mixer2
        
        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)
        
        mixer2.addInput(player)
        
        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)
    }

    func testTransientNodes() throws {
        try XCTSkipIf(true, "TODO Skipped test")

        let engine = AudioEngine()
        let player = Sampler()
        func exampleStart() {
            engine.output = player
            try! engine.start()
            player.play(url: URL.testAudio)
            sleep(1)
        }
        func exampleStop() {
            player.stop()
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

    // This provides a baseline for measuring the overhead
    // of mixers in testMixerPerformance.
    func testChainPerformance() {
        let engine = Engine()
        let player = Sampler()
        
        let rev = Reverb(player)
        
        engine.output = rev
        
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play(url: URL.testAudio)
            
            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()
            
            audio.append(buf)
        }
    }
    
    // Measure the overhead of mixers.
    func testMixerPerformance() {
        let engine = Engine()
        let player = Sampler()
        
        let mix1 = Mixer(player)
        let rev = Reverb(mix1)
        let mix2 = Mixer(rev)
        
        engine.output = mix2
        
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play(url: URL.testAudio)
            
            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()
            
            audio.append(buf)
        }
    }
    
    func testGraphviz() {
        let sampler = Sampler()
        
        let verb = Reverb(sampler)
        let mixer = Mixer(sampler, verb)
        
        let dot = mixer.graphviz
        
        // Note that output depends on memory addresses.
        print(dot)
    }

    func testAllNodesInChainDeallocatedOnRemove() {
        let engine = Engine()
        var chain: Node? = createChain()
        weak var weakPitch = chain?.avAudioNode
        weak var weakDelay = chain?.connections.first?.avAudioNode
        weak var weakPlayer = chain?.connections.first?.connections.first?.avAudioNode
        let mixer = Mixer(chain!, createChain())
        engine.output = mixer

        mixer.removeInput(chain!)
        chain = nil

        XCTAssertNil(weakPitch)
        XCTAssertNil(weakDelay)
        XCTAssertNil(weakPlayer)
    }

    @available(iOS 13.0, *)
    func testNodesThatHaveOtherConnectionsNotDeallocated() {
        let engine = Engine()
        var chain: Node? = createChain()
        weak var weakPitch = chain?.avAudioNode
        weak var weakDelay = chain?.connections.first?.avAudioNode
        weak var weakPlayer = chain?.connections.first?.connections.first?.avAudioNode
        let mixer1 = Mixer(chain!, createChain())
        let mixer2 = Mixer(mixer1, chain!)
        engine.output = mixer2

        mixer1.removeInput(chain!)
        chain = nil

        XCTAssertNotNil(weakPitch)
        XCTAssertNotNil(weakDelay)
        XCTAssertNotNil(weakPlayer)
    }

    @available(iOS 13.0, *)
    func testInnerNodesThatHaveOtherConnectionsNotDeallocated() {
        let engine = AudioEngine()
        var chain: Node? = createChain()
        weak var weakPitch = chain?.avAudioNode
        weak var weakDelayNode = chain?.connections.first
        weak var weakDelay = chain?.connections.first?.avAudioNode
        weak var weakPlayer = chain?.connections.first?.connections.first?.avAudioNode
        let mixer = Mixer(chain!, createChain(), weakDelayNode!)
        engine.output = mixer

        mixer.removeInput(chain!)
        chain = nil

        XCTAssertNil(weakPitch)
        XCTAssertNotNil(weakDelay)
        XCTAssertNotNil(weakDelayNode)
        XCTAssertNotNil(weakPlayer)
        XCTAssertTrue(engine.avEngine.attachedNodes.contains(weakDelay!))
        XCTAssertTrue(engine.avEngine.attachedNodes.contains(weakPlayer!))
    }

    // This is a test for workaround for:
    // http://openradar.appspot.com/radar?id=5490575180562432
    // Connection format is not correctly applied when adding a node to paused engine
    // This is only happening when using destination point API with one point
    #if !os(tvOS)
    func testConnectionFormatAppliedWhenAddingNode() throws {
        let engine = AudioEngine()
        let previousFormat = Settings.audioFormat

        var settings = Settings.audioFormat.settings
        settings[AVSampleRateKey] = 48000
        Settings.audioFormat = AVAudioFormat(settings: settings)!

        let mixer = Mixer(MIDISampler())
        engine.output = mixer
        try engine.start()
        engine.pause()

        let sampler = MIDISampler()
        mixer.addInput(sampler)

        XCTAssertEqual(sampler.avAudioNode.outputFormat(forBus: 0).sampleRate, 48000)

        Settings.audioFormat = previousFormat
    }
    #endif
}

private extension NodeTests {
    func createChain() -> Node { TimePitch(Delay(Sampler())) }
}
