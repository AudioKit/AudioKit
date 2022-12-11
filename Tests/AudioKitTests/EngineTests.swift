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
        
        audio.audition()
    }

    func testBasicRealtime() throws {
        let engine = Engine()

        let osc = TestOscillator()

        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)

        engine.output = osc
        try! engine.start()

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 1)

        sleep(1)
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

        audio.audition()
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

        audio.audition()
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
    func testDynamicChange() throws {
        
        let engine = Engine()
        
        let osc = TestOscillator()
        let dist = AppleDistortion(osc)
        
        engine.output = osc

        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist
        
        audio.append(engine.render(duration: 1.0))

        audio.audition()
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
    
    func testMixer() throws {
        
        let engine = Engine()
        
        let osc1 = TestOscillator()
        let osc2 = TestOscillator()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1, osc2])
        
        engine.output = mix
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        audio.audition()
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

        audio.audition()
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

        audio.audition()
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
        let file = try! AVAudioFile(forReading: url)
        let sampler = Sampler(file: file)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play()
        audio.append(engine.render(duration: 2.0))
        audio.audition()
    }

    func testSamplerRealtime() throws {
        let engine = Engine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let file = try! AVAudioFile(forReading: url)
        let sampler = Sampler(file: file)
        engine.output = sampler
        try engine.start()
        sampler.play()
        sleep(2)
    }

    func testCompressorWithSampler() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let file = try! AVAudioFile(forReading: url)
        let sampler = Sampler(file: file)
        engine.output = Compressor(sampler, attackTime: 0.1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play()
        audio.append(engine.render(duration: 1.0))
        audio.audition()
    }

    func testPlaygroundOscillator() {
        let engine = Engine()
        let osc = PlaygroundOscillator()
        engine.output = osc
        let audio = engine.startTest(totalDuration: 2.0)
        osc.play()
        audio.append(engine.render(duration: 2.0))
        audio.audition()
    }

}
