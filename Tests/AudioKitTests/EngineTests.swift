// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class EngineTests: XCTestCase {
    
    func testBasic() throws {
        let engine = Engine()
        
        let osc = TestOscillator()
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = osc

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 1)

        testMD5(audio)
    }

    func testEffect() throws {
        
        let engine = Engine()
        
        let osc = TestOscillator()
        let fx = AppleDistortion(osc)
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = fx
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 2)

        testMD5(audio)
    }

    func testTwoEffects() throws {
        
        let engine = Engine()
        
        let osc = TestOscillator()
        let dist = AppleDistortion(osc)
        let rev = Reverb(dist)
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = rev
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 3)

        testMD5(audio)
    }
    
    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        
        let engine = Engine()
        
        let osc = TestOscillator()
        let dist = AppleDistortion(osc)
        
        engine.output = osc

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist
        
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }
    
    func testMixer() throws {
        
        let engine = Engine()
        
        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1, osc2])
        
        engine.output = mix
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerVolume() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it

        let mix = Mixer([osc1, osc2])

        // XXX: ensure we get the same output using AVAudioEngine
        mix.volume = 0.02

        engine.output = mix

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        testMD5(audio)
    }

    func testMixerDynamic() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
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

        ///  XXX: Volume of zero produces silence in both cases but not the same md5!
        for volume in [0.1, 0.5, 0.8, 1.0, 2.0] {
            let audioEngine = AudioEngine()
            let osc = TestOscillator()
            let mix = Mixer(osc)
            mix.volume = AUValue(volume)
            audioEngine.output = mix
            let audio = audioEngine.startTest(totalDuration: 1.0)
            audio.append(audioEngine.render(duration: 1.0))

            let engine = Engine()
            let osc2 = TestOscillator()
            let mix2 = Mixer(osc2)
            mix2.volume = AUValue(volume)
            engine.output = mix2
            let audio2 = engine.startTest(totalDuration: 1.0)
            audio2.append(engine.render(duration: 1.0))

            for i in 0..<Int(audio.frameLength) {
                let s0 = audio.floatChannelData![0][i]
                let s1 = audio2.floatChannelData![0][i]
                XCTAssertEqual(s0, s1)
            }
        }
    }

    /// Test some number of changes so schedules are released.
    func testMultipleChanges() throws {

        let engine = Engine()

        let osc1 = TestOscillator()
        let osc2 = TestOscillator()

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
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let sampler = Sampler()
        sampler.play(url: url)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play()
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSamplerMIDINote() {
        let engine = Engine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let sampler = Sampler()
        sampler.assign(url: url, to: 60)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.playMIDINote(60)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testCompressorWithSampler() {
        let engine = Engine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let buffer = try! AVAudioPCMBuffer(url: url)!
        let sampler = Sampler()
        sampler.play(buffer)
        engine.output = Compressor(sampler, attackTime: 0.1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPlaygroundOscillator() {
        let engine = Engine()
        let osc = PlaygroundOscillator()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 2.0)
        osc.play()
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    #if false
    func testRingBuffer() {
        let buffer = RingBuffer<Float>()

        let pushResult = buffer.push(1.666)

        XCTAssertTrue(pushResult)
        XCTAssertEqual(buffer.fillCount.load(ordering: .relaxed), 1)

        let popResult = buffer.pop()

        XCTAssertEqual(buffer.fillCount.load(ordering: .relaxed), 0)
        XCTAssertEqual(popResult, 1.666)

        var floats: [Float] = [1, 2, 3, 4, 5]

        _ = floats.withUnsafeBufferPointer { ptr in
            buffer.push(from: ptr)
        }


        XCTAssertEqual(Int(buffer.fillCount.load(ordering: .relaxed)), floats.count)

        floats = [0, 0, 0, 0, 0]

        _ = floats.withUnsafeMutableBufferPointer { ptr in
            buffer.pop(to: ptr)
        }

        XCTAssertEqual(floats, [1, 2, 3, 4, 5])

    }
    #endif

    func testSysexEncoding() {

        let value = 42
        let sysex = encodeSysex(value)

        XCTAssertEqual(sysex.count, 19)

        var decoded = 0
        decodeSysex(sysex, count: 19, &decoded)

        XCTAssertEqual(decoded, 42)
    }

}
