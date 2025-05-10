// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeTests: XCTestCase {

    override func setUp() {
        Settings.sampleRate = 44100
    }

    func testNodeBasic() {
        let engine = AudioEngine()
        let player = AudioPlayer(testFile: "12345")
        XCTAssertNil(player.avAudioNode.engine)
        engine.output = player
        XCTAssertNotNil(player.avAudioNode.engine)
        let audio = engine.startTest(totalDuration: 0.1)
        player.play()
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    #if os(macOS) // For some reason failing on iOS and tvOS
    func testNodeConnection() {
        let engine = AudioEngine()
        let player = AudioPlayer(testFile: "12345")
        let verb = Reverb(player)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }
    #endif

    func testNodeOutputFormatRespected() {
        let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 2)!
        let engine = AudioEngine()
        let player = AudioPlayer(testFile: "12345")
        let verb = CustomFormatReverb(player, outputFormat: outputFormat)
        engine.output = verb

        XCTAssertEqual(engine.mainMixerNode!.avAudioNode.inputFormat(forBus: 0), outputFormat)
        XCTAssertEqual(verb.avAudioNode.inputFormat(forBus: 0), Settings.audioFormat)
    }
    
    func testRedundantConnection() {
        let player = AudioPlayer(testFile: "12345")
        let mixer = Mixer()
        mixer.addInput(player)
        mixer.addInput(player)
        mixer.addInput(player, strategy: .incremental)
        XCTAssertEqual(mixer.connections.count, 1)
    }
    
    func testDynamicOutput() {
        let engine = AudioEngine()

        let player1 = AudioPlayer(testFile: "12345")
        engine.output = player1
        
        let audio = engine.startTest(totalDuration: 2.0)
        player1.play()
        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let player2 = AudioPlayer(testFile: "drumloop")
        engine.output = player2
        player2.play()
        
        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)
        
        testMD5(audio)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testDynamicConnection() {
        let engine = AudioEngine()
        
        let osc1 = PlaygroundOscillator(waveform: Table(.triangle), frequency: 440, amplitude: 0.1)
        let mixer = Mixer(osc1)
        
        XCTAssertNil(osc1.avAudioNode.engine)
        
        engine.output = mixer
        
        // Osc should be attached.
        XCTAssertNotNil(osc1.avAudioNode.engine)
        
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

        let engine = AudioEngine()

        let player1 = AudioPlayer(testFile: "12345")
        let mixer = Mixer(player1)

        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)
        player1.play()

        audio.append(engine.render(duration: 1.0))

        let player2 = AudioPlayer(testFile: "drumloop")
        let verb = Reverb(player2)
        player2.play()
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }

    func testDynamicConnection3() throws {
        try XCTSkipIf(true, "TODO Skipped test")

        let engine = AudioEngine()

        let player1 = AudioPlayer(testFile: "12345")
        let mixer = Mixer(player1)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 3.0)
        player1.play()
        
        audio.append(engine.render(duration: 1.0))

        let player2 = AudioPlayer(testFile: "drumloop")
        mixer.addInput(player2)

        player2.play()

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(player2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection4() throws {
        try XCTSkipIf(true, "TODO Skipped test")
        let engine = AudioEngine()
        let outputMixer = Mixer()
        let player1 = AudioPlayer(testFile: "12345")
        outputMixer.addInput(player1)
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 2.0)

        player1.play()
        
        audio.append(engine.render(duration: 1.0))

        let player2 = AudioPlayer(testFile: "drumloop")

        let localMixer = Mixer()
        localMixer.addInput(player2)
        outputMixer.addInput(localMixer)

        player2.play()
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection5() throws {
        try XCTSkipIf(true, "TODO Skipped test")
        let engine = AudioEngine()
        let outputMixer = Mixer()
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 1.0)

        let player = AudioPlayer(testFile: "12345")
        
        let mixer = Mixer()
        mixer.addInput(player)

        outputMixer.addInput(mixer) // change mixer to osc and this will play

        player.play()
        
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDisconnect() {
        let engine = AudioEngine()

        let player = AudioPlayer(testFile: "12345")
        
        let mixer = Mixer(player)
        engine.output = mixer
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        player.play()
        
        audio.append(engine.render(duration: 1.0))
        
        mixer.removeInput(player)
        
        audio.append(engine.render(duration: 1.0))
        
        testMD5(audio)
    }
    
    func testNodeDetach() {
        let engine = AudioEngine()
        
        let player = AudioPlayer(testFile: "12345")
        
        let mixer = Mixer(player)
        engine.output = mixer
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        player.play()
        
        audio.append(engine.render(duration: 1.0))
        
        player.detach()
        
        audio.append(engine.render(duration: 1.0))
        
        testMD5(audio)
    }

    func testNodeStatus() {
        let url = Bundle.module.url(forResource: "chromaticScale-1",
                                    withExtension: "aiff",
                                    subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        XCTAssertTrue(player.status == .stopped, "Player status should be '.stopped'")

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()
        player.play()
        XCTAssertTrue(player.status == .playing, "Player status should be '.playing'")
        player.play()
        XCTAssertTrue(player.status == .playing, "Player status should be '.playing'")
        player.pause()
        XCTAssertTrue(player.status == .paused, "Player status should be '.paused'")
        player.play()
        XCTAssertTrue(player.status == .playing, "Player status should be '.playing'")
        player.pause()
        XCTAssertTrue(player.status == .paused, "Player status should be '.paused'")
        player.resume()
        XCTAssertTrue(player.status == .playing, "Player status should be '.playing'")
        player.stop()
    }

    func testTwoEngines() {
        let engine = AudioEngine()
        let engine2 = AudioEngine()
        
        let player = AudioPlayer(testFile: "12345")
        
        engine2.output = player
        
        let verb = Reverb(player)
        engine.output = verb
        
        let audio = engine.startTest(totalDuration: 0.1)
        player.play()
        
        audio.append(engine.render(duration: 0.1))
        XCTAssert(audio.isSilent)
    }
    
    func testManyMixerConnections() {
        let engine = AudioEngine()
        
        var players: [AudioPlayer] = []
        for _ in 0 ..< 16 {
            players.append(AudioPlayer())
        }
        
        let mixer = Mixer(players)
        engine.output = mixer
        
        XCTAssertEqual(mixer.avAudioNode.inputCount, 16)
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
        let player = AudioPlayer(testFile: "12345")
        
        let verb = Reverb(player)
        let mixer = Mixer(player, verb)
        engine.output = mixer
        
        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }
    
    func testMixerRedundantUpstreamConnection() {
        let engine = AudioEngine()

        let player = AudioPlayer(testFile: "12345")
        
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
        let player = AudioPlayer(testFile: "12345")
        func exampleStart() {
            engine.output = player
            try! engine.start()
            player.play()
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
        let engine = AudioEngine()
        let player = AudioPlayer(testFile: "12345")
        
        let rev = Reverb(player)
        
        XCTAssertNil(player.avAudioNode.engine)
        engine.output = rev
        XCTAssertNotNil(player.avAudioNode.engine)
        
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play()
            
            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()
            
            audio.append(buf)
        }
    }
    
    // Measure the overhead of mixers.
    func testMixerPerformance() {
        let engine = AudioEngine()
        let player = AudioPlayer(testFile: "12345")
        
        let mix1 = Mixer(player)
        let rev = Reverb(mix1)
        let mix2 = Mixer(rev)
        
        XCTAssertNil(player.avAudioNode.engine)
        engine.output = mix2
        XCTAssertNotNil(player.avAudioNode.engine)
        
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play()
            
            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()
            
            audio.append(buf)
        }
    }
    
    func testConnectionTreeDescriptionForStandaloneNode() {
        let player = AudioPlayer(testFile: "12345")
        XCTAssertEqual(player.connectionTreeDescription, "\(connectionTreeLinePrefix)↳AudioPlayer")
    }
    
    func testConnectionTreeDescriptionForConnectedNode() {
        let player = AudioPlayer(testFile: "12345")
        
        let verb = Reverb(player)
        let mixer = Mixer(player, verb)
        let mixerAddress = MemoryAddress(of: mixer).description
        
        XCTAssertEqual(mixer.connectionTreeDescription,
                       """
        \(connectionTreeLinePrefix)↳Mixer("\(mixerAddress)")
        \(connectionTreeLinePrefix) ↳AudioPlayer
        \(connectionTreeLinePrefix) ↳Reverb
        \(connectionTreeLinePrefix)  ↳AudioPlayer
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
    
    func testGraphviz() {
        let player = AudioPlayer(testFile: "12345")
        player.label = "MyAwesomePlayer"

        let verb = Reverb(player)
        let mixer = Mixer(player, verb)
        
        let dot = mixer.graphviz
        
        // Note that output depends on memory addresses.
        print(dot)
    }

    func testAllNodesInChainDeallocatedOnRemove() {
        for strategy in [DisconnectStrategy.recursive, .detach] {
            let engine = AudioEngine()
            var chain: Node? = createChain()
            weak var weakPitch = chain?.avAudioNode
            weak var weakDelay = chain?.connections.first?.avAudioNode
            weak var weakPlayer = chain?.connections.first?.connections.first?.avAudioNode
            let mixer = Mixer(chain!, createChain())
            engine.output = mixer

            mixer.removeInput(chain!, strategy: strategy)
            chain = nil

            XCTAssertNil(weakPitch)
            XCTAssertNil(weakDelay)
            XCTAssertNil(weakPlayer)

            XCTAssertFalse(engine.avEngine.description.contains("other nodes"))
        }
    }

    @available(iOS 13.0, *)
    func testNodesThatHaveOtherConnectionsNotDeallocated() {
        let engine = AudioEngine()
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
        XCTAssertTrue(engine.avEngine.attachedNodes.contains(weakPitch!))
        XCTAssertTrue(engine.avEngine.attachedNodes.contains(weakDelay!))
        XCTAssertTrue(engine.avEngine.attachedNodes.contains(weakPlayer!))
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

    @available(iOS 13.0, *)
    func testInnerNodesThatHaveMultipleInnerConnectionsDeallocated() {
        for strategy in [DisconnectStrategy.recursive, .detach] {
            let engine = AudioEngine()
            var chain: Node? = createChain()
            weak var weakPitch = chain?.avAudioNode
            weak var weakDelay = chain?.connections.first?.avAudioNode
            weak var weakPlayer = chain?.connections.first?.connections.first?.avAudioNode
            var mixer: Mixer? = Mixer(chain!, Mixer(chain!))
            var outer: Mixer? = Mixer(mixer!)
            engine.output = outer

            outer!.removeInput(mixer!, strategy: strategy)
            outer = nil
            mixer = nil
            chain = nil

            XCTAssertNil(weakPitch)
            XCTAssertNil(weakDelay)
            XCTAssertNil(weakPlayer)

            // http://openradar.appspot.com/radar?id=5616162842869760
            // This condition should be passing, but unfortunately,
            // under certain conditions, it is not due to a bug.

            // XCTAssertFalse(engine.avEngine.description.contains("other nodes"))
        }
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
    func createChain() -> Node { TimePitch(Delay(AudioPlayer())) }
}

extension AudioPlayer {
    convenience init(testFile: String) {
        let url = Bundle.module.url(forResource: testFile, withExtension: "wav", subdirectory: "TestResources")!
        self.init(url: url)!
    }
}
