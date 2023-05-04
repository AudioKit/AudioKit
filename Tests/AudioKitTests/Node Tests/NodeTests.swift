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
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 0.1))
        testMD5(audio)
    }

    #if os(macOS)
    func testNodeConnection() {
        let engine = Engine()
        let sampler = Sampler()
        let verb = Reverb(sampler)
        engine.output = verb
        let audio = engine.startTest(totalDuration: 0.1)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 0.1))
        XCTAssertFalse(audio.isSilent)
        testMD5(audio)
        audio.audition()
    }
    #endif

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
        sampler1.play(url: .testAudio)
        let newAudio = engine.render(duration: 1.0)
        audio.append(newAudio)

        let sampler2 = Sampler()
        engine.output = sampler2
        sampler2.play(url: .testAudioDrums)

        let newAudio2 = engine.render(duration: 1.0)
        audio.append(newAudio2)

        testMD5(audio)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testDynamicConnection() {
        let engine = Engine()

        let osc1 = Oscillator(waveform: Table(.triangle), frequency: 440, amplitude: 0.1)
        let mixer = Mixer(osc1)

        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        let osc2 = Oscillator(waveform: Table(.triangle), frequency: 880, amplitude: 0.1)
        mixer.addInput(osc2)

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
        sampler1.play(url: .testAudio)

        audio.append(engine.render(duration: 1.0))

        let sampler2 = Sampler()
        let verb = Distortion(sampler2)
        sampler2.play(url: .testAudioDrums)
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
        sampler1.play(url: .testAudio)

        audio.append(engine.render(duration: 1.0))

        let sampler2 = Sampler()
        mixer.addInput(sampler2)

        sampler2.play(url: .testAudioDrums)

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

        player1.play(url: .testAudio)

        audio.append(engine.render(duration: 1.0))

        let player2 = Sampler()

        let localMixer = Mixer()
        localMixer.addInput(player2)
        outputMixer.addInput(localMixer)

        player2.play(url: .testAudioDrums)
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

        player.play(url: .testAudio)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testDisconnect() {
        let engine = Engine()

        let player = Sampler()

        let mixer = Mixer(player)
        engine.output = mixer

        let audio = engine.startTest(totalDuration: 2.0)

        player.play(url: .testAudio)

        audio.append(engine.render(duration: 1.0))

        mixer.removeInput(player)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    // This provides a baseline for measuring the overhead
    // of mixers in testMixerPerformance.
    func testChainPerformance() {
        let engine = Engine()
        let player = Sampler()

        let rev = Distortion(player)

        engine.output = rev

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play(url: .testAudio)

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
        let rev = Distortion(mix1)
        let mix2 = Mixer(rev)

        engine.output = mix2

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let audio = engine.startTest(totalDuration: 10.0)
            player.play(url: .testAudio)

            startMeasuring()
            let buf = engine.render(duration: 10.0)
            stopMeasuring()

            audio.append(buf)
        }
    }

    func testGraphviz() {
        let sampler = Sampler()

        let verb = Distortion(sampler)
        let mixer = Mixer(sampler, verb)

        let dot = mixer.graphviz

        // Note that output depends on memory addresses.
        print(dot)
    }

    func testNodeLeak() throws {

        let initialEngineCount = EngineAudioUnit.instanceCount.load(ordering: .relaxed)
        let initialNoiseCount = Noise.instanceCount.load(ordering: .relaxed)

        let scope = {
            let engine = Engine()
            let noise = Noise()
            noise.amplitude = 0.1

            engine.output = noise

            try engine.start()
            sleep(1)
            engine.stop()
        }

        try scope()

        sleep(1)

        XCTAssertEqual(EngineAudioUnit.instanceCount.load(ordering: .relaxed), initialEngineCount, "leaked EngineAudioUnit")
        XCTAssertEqual(Noise.instanceCount.load(ordering: .relaxed), initialNoiseCount, "leaked Noise node")
    }
}
