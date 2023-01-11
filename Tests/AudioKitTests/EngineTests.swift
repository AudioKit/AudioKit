// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class EngineTests: XCTestCase {
    
    func testBasic() throws {
        let engine = Engine()
        
        let osc = Oscillator()

        engine.output = osc

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testEffect() throws {
        
        let engine = Engine()
        
        let osc = Oscillator()
        let fx = Distortion(osc)

        engine.output = fx
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testTwoEffects() throws {
        
        let engine = Engine()
        
        let osc = Oscillator()
        let dist = Distortion(osc)
        let rev = Reverb(dist)

        engine.output = rev
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }
    
    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        
        let engine = Engine()
        
        let osc = Oscillator()
        let dist = Distortion(osc)
        
        engine.output = osc

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist
        
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }
    
    func testMixer() throws {
        
        let engine = Engine()
        
        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1, osc2])
        
        engine.output = mix
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume() throws {

        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        mix.volume = 0.02

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerDynamic() throws {

        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1])

        engine.output = mix

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        mix.addInput(osc2)

        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume2() throws {

        let avAudioEngineMixerMD5s: [String] = [
            "07a5ba764493617dcaa54d16e8cbec99",
            "41be8ab2c3d61d3cb61bf5c7a1e06d42",
            "66cc591ea1974ff7f0fef36d4faf1453",
            "e2dadccf46c5bf77ec19232750150a99",
            "f5b785dcc74759b4a0492aef430bfc2e",
            "0e20255d8d106d37c95262f229aed527"
        ]

        for (index, volume) in [0.0, 0.1, 0.5, 0.8, 1.0, 2.0].enumerated() {
            let engine = Engine()
            let osc = Oscillator()
            let mix = Mixer(osc)
            mix.volume = AUValue(volume)
            engine.output = mix
            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            XCTAssertEqual(audio.md5, avAudioEngineMixerMD5s[index])
        }
    }

    func testMixerPan() throws {
        let duration = 1.0

        let avAudioEngineMixerMD5s: [String] = [
            "111472eeef40ef621e484fa7d164ce07",
            "d908a41c25f1087cb4acfa40ba98192b",
            "ab42b58d273e3fbd9d0bc2bf0406a6a2",
            "ccfca4edd61c3f9ab8091b99d944d148",
            "1bdd778d0a674c1b1d139066599c80b6",
            "0bd0c266c681114276729d09bbc4178f",
            "f9c92e3084ed6cabdc6934c51e6b730e"
        ]

        for (index, pan) in [-0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75].enumerated() {
            let engine = Engine()
            let oscL = Oscillator()
            let oscR = Oscillator()
            oscR.frequency = 500
            let mixL = Mixer(oscL)
            let mixR = Mixer(oscR)
            mixL.pan = -1.0
            mixR.pan = 1.0
            let mixer = Mixer(mixL, mixR)
            mixer.pan = AUValue(pan)
            engine.output = mixer
            let audio = engine.startTest(totalDuration: duration)
            audio.append(engine.render(duration: duration))

            XCTAssertEqual(avAudioEngineMixerMD5s[index], audio.md5)
        }
    }


    /// Test some number of changes so schedules are released.
    func testMultipleChanges() throws {

        let engine = Engine()

        let osc1 = Oscillator()
        let osc2 = Oscillator()

        osc1.frequency = 880

        engine.output = osc1

        let audio = engine.startTest(totalDuration: 10.0)

        for i in 0..<10 {
            audio.append(engine.render(duration: 1.0))
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }

        testMD5(audio)
    }

    /// Lists all AUs on the system so we can identify which Apple ones are available.
    func testListAUs() throws {

        let auManager = AVAudioUnitComponentManager.shared()

        // Get an array of all available Audio Units
        let audioUnits = auManager.components(passingTest: { _, _ in true })

        for audioUnit in audioUnits {
            // Get the audio unit's name
            let name = audioUnit.name

            print("Audio Unit: \(name)")
        }
    }

    func testSampler() {
        let engine = Engine()
        let sampler = Sampler()
        sampler.play(url: URL.testAudio)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play()
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSamplerMIDINote() {
        let engine = Engine()
        let sampler = Sampler()
        sampler.assign(url: URL.testAudio, to: 60)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.playMIDINote(60)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testDynamicsProcessorWithSampler() {
        let engine = Engine()
        let buffer = try! AVAudioPCMBuffer(url: URL.testAudio)!
        let sampler = Sampler()
        sampler.play(buffer)
        engine.output = DynamicsProcessor(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testOscillator() {
        let engine = Engine()
        let osc = Oscillator()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 2.0)
        osc.play()
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSysexEncoding() {

        let value = 42
        let sysex = encodeSysex(value)

        XCTAssertEqual(sysex.count, 19)

        var decoded = 0
        decodeSysex(sysex, count: 19, &decoded)

        XCTAssertEqual(decoded, 42)
    }

    func testManyOscillatorsPerf() throws {
        let engine = Engine()

        let mixer = Mixer()

        for _ in 0..<100 {
            mixer.addInput(Oscillator())
        }

        mixer.volume = 0.001
        engine.output = mixer

        measure {
            let audio = engine.startTest(totalDuration: 2.0)
            audio.append(engine.render(duration: 2.0))
        }
    }

}
