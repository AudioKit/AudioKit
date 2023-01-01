// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineRelatimeTests: XCTestCase {

    func testBasicRealtime() throws {
        let engine = Engine()

        let osc = TestOscillator()

        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)

        engine.output = osc
        try! engine.start()

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 1)

        sleep(1)
    }


    func testEffectRealtime() throws {

        let engine = Engine()

        let osc = TestOscillator()
        let fx = AppleDistortion(osc)

        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)

        engine.output = fx
        try engine.start()

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 2)

        sleep(1)
    }

    func testTwoEffectsRealtime() throws {

        let engine = Engine()

        let osc = TestOscillator()
        let dist = AppleDistortion(osc)
        let rev = Reverb(dist)

        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)

        engine.output = rev

        try engine.start()

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 3)

        sleep(1)
    }

    /// Test changing the output chain on the fly.
    func testDynamicChangeRealtime() throws {

        let engine = Engine()

        let osc = TestOscillator()
        let dist = AppleDistortion(osc)

        engine.output = osc
        try engine.start()

        sleep(1)

        engine.output = dist

        sleep(1)
    }

    func testMixerRealtime() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        engine.output = mix

        try engine.start()

        sleep(1)
    }

    func testMixerDynamicRealtime() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1])

        engine.output = mix

        try engine.start()

        sleep(1)

        mix.addInput(osc2)

        sleep(1)
    }

    func testMultipleChangesRealtime() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()

        osc1.frequency = 880

        engine.output = osc1

        try engine.start()

        for i in 0..<10 {
            sleep(1)
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }
    }

    func testSamplerRealtime() throws {
        let engine = Engine()
        let url = URL.testAudio
        let buffer = try! AVAudioPCMBuffer(url: url)!
        let sampler = Sampler()
        
        engine.output = sampler
        try engine.start()
        sampler.play()
        sleep(1)
        sampler.play(buffer)
        sleep(2)
    }

    func testManyOscillators() throws {
        let engine = Engine()

        let mixer = Mixer()

        for _ in 0..<100 {
            mixer.addInput(TestOscillator())
        }

        mixer.volume = 0.001
        engine.output = mixer

        try engine.start()
        sleep(2)
    }

    func testManyOscillatorsOld() throws {
        let engine = AudioEngine()

        let mixer = Mixer()

        for _ in 0..<100 {
            mixer.addInput(TestOscillator())
        }

        mixer.volume = 0.001
        engine.output = mixer

        try engine.start()
        sleep(2)
    }

}
