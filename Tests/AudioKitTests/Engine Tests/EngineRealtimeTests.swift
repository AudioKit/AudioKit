// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineRealtimeTests: AKTestCase {
    func testBasicRealtime() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        osc.amplitude = 0.1

        engine.output = osc
        try! engine.start()

        usleep(100_000)
    }

    func testEffectRealtime() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let fx = Distortion(osc)

        engine.output = fx

        osc.amplitude = 0.1

        try engine.start()

        usleep(100_000)
    }

    func testTwoEffectsRealtime() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let dist = Distortion(osc)
        let rev = Distortion(dist)

        engine.output = rev

        try engine.start()

        osc.amplitude = 0.1

        usleep(100_000)
    }

    /// Test changing the output chain on the fly.
    func testDynamicChangeRealtime() throws {
        let engine = AudioEngine()

        let osc = TestOscillator()
        let dist = Distortion(osc)

        engine.output = osc
        try engine.start()

        usleep(100_000)

        engine.output = dist

        osc.amplitude = 0.1

        usleep(100_000)
    }

    func testMixerRealtime() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        engine.output = mix

        try engine.start()

        osc1.amplitude = 0.1
        osc2.amplitude = 0.1

        usleep(100_000)
    }

    func testMixerDynamicRealtime() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1])

        engine.output = mix

        osc1.amplitude = 0.1
        osc2.amplitude = 0.1

        try engine.start()

        usleep(100_000)

        mix.addInput(osc2)

        usleep(100_000)
    }

    func testMultipleChangesRealtime() throws {
        let engine = AudioEngine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()

        osc1.frequency = 880

        engine.output = osc1

        osc1.amplitude = 0.1
        osc2.amplitude = 0.1

        try engine.start()

        for i in 0 ..< 10 {
            usleep(100_000)
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }
    }

    func testSamplerRealtime() throws {
        let engine = AudioEngine()
        let url = URL.testAudio
        let buffer = try! AVAudioPCMBuffer(url: url)!
        let sampler = Sampler()

        engine.output = sampler
        try engine.start()
        usleep(100_000)
        sampler.play(buffer)
        sleep(2)
    }

    func testManyOscillators() throws {
        let engine = AudioEngine()

        let mixer = Mixer()

        for _ in 0 ..< 100 {
            let osc = TestOscillator()
            mixer.addInput(osc)
        }

        mixer.volume = 0.001
        engine.output = mixer

        try engine.start()
        sleep(2)
    }
}
