// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class NodeTests: XCTestCase {
    func testNodeBasic() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        XCTAssertNil(player.avAudioNode.engine)
        engine.output = player
        XCTAssertNotNil(player.avAudioNode.engine)
        let audio = engine.startTest(totalDuration: 0.1)
        player.play()
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }
    
    func testNodeConnection() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let verb = Reverb(player)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }
    
    func testRedundantConnection() {
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let mixer = Mixer()
        mixer.addInput(player)
        mixer.addInput(player)
        XCTAssertEqual(mixer.connections.count, 1)
    }
    
    func testDynamicOutput() {
        let engine = AudioEngine()
        
        let url1 = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player1 = AudioPlayer(url: url1)!
        engine.output = player1
        
        let audio = engine.startTest(totalDuration: 2.0)
        player1.play()
        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)
        
        let url2 = Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
        let player2 = AudioPlayer(url: url2)!
        engine.output = player2
        player2.play()
        
        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)
        
        testMD5(audio)
    }
    
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
    
    /*

    func testDynamicConnection2() {
        let engine = AudioEngine()

        let url1 = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player1 = AudioPlayer(url: url1)!
        let mixer = Mixer(player1)

        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)
        player1.play()

        audio.append(engine.render(duration: 1.0))

        let url2 = Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
        let player2 = AudioPlayer(url: url2)!
        let verb = Reverb(player2)
        player2.play()
        mixer.addInput(verb)

        audio.append(engine.render(duration: 1.0))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
    }

    func testDynamicConnection3() {
        let engine = AudioEngine()

        let url1 = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player1 = AudioPlayer(url: url1)!
        let mixer = Mixer(player1)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 3.0)
        player1.play()
        
        audio.append(engine.render(duration: 1.0))

        let url2 = Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
        let player2 = AudioPlayer(url: url2)!
        mixer.addInput(player2)

        player2.play()

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(player2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection4() {
        let engine = AudioEngine()
        let outputMixer = Mixer()
        let url1 = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player1 = AudioPlayer(url: url1)!
        outputMixer.addInput(player1)
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 2.0)

        player1.play()
        
        audio.append(engine.render(duration: 1.0))

        let url2 = Bundle.module.url(forResource: "drumloop", withExtension: "wav", subdirectory: "TestResources")!
        let player2 = AudioPlayer(url: url2)!

        let localMixer = Mixer()
        localMixer.addInput(player2)
        outputMixer.addInput(localMixer)

        player2.play()
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDynamicConnection5() {
        let engine = AudioEngine()
        let outputMixer = Mixer()
        engine.output = outputMixer
        let audio = engine.startTest(totalDuration: 1.0)

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
        let mixer = Mixer()
        mixer.addInput(player)

        outputMixer.addInput(mixer) // change mixer to osc and this will play

        player.play()
        
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }
 
 */

    func testDisconnect() {
        let engine = AudioEngine()
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
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
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
        let mixer = Mixer(player)
        engine.output = mixer
        
        let audio = engine.startTest(totalDuration: 2.0)
        
        player.play()
        
        audio.append(engine.render(duration: 1.0))
        
        player.detach()
        
        audio.append(engine.render(duration: 1.0))
        
        testMD5(audio)
    }
    
    func testTwoEngines() {
        let engine = AudioEngine()
        let engine2 = AudioEngine()
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
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
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
        let verb = Reverb(player)
        let mixer = Mixer(player, verb)
        engine.output = mixer
        
        XCTAssertEqual(connectionCount(node: verb.avAudioNode), 1)
        XCTAssertEqual(connectionCount(node: mixer.avAudioNode), 2)
    }
    
    func testMixerRedundantUpstreamConnection() {
        let engine = AudioEngine()
        
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
        let mixer1 = Mixer(player)
        let mixer2 = Mixer(mixer1)
        
        engine.output = mixer2
        
        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)
        
        mixer2.addInput(player)
        
        XCTAssertEqual(connectionCount(node: mixer1.avAudioNode), 1)
    }

//    func testTransientNodes() {
//        let engine = AudioEngine()
//        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
//        let player = AudioPlayer(url: url)!
//        func exampleStart() {
//            let env = AmplitudeEnvelope(player)
//            engine.output = env
//            try! engine.start()
//            player.play()
//            sleep(1)
//        }
//        func exampleStop() {
//            player.stop()
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

    /* TODO
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
 */

    // This provides a baseline for measuring the overhead
    // of mixers in testMixerPerformance.
    func testChainPerformance() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
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
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
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
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        XCTAssertEqual(player.connectionTreeDescription, "\(connectionTreeLinePrefix)↳AudioPlayer")
    }
    
    func testConnectionTreeDescriptionForConnectedNode() {
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        
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
}
