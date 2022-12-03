// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class Engine2Tests: XCTestCase {
    
    func testBasic() throws {
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = osc

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 1)
        
        audio.audition()
    }
    
    func testEffect() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let fx = AppleDistortion(osc)
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = fx
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 2)

        audio.audition()
    }
    
    func testTwoEffects() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let dist = AppleDistortion(osc)
        let rev = Reverb(dist)
        
        XCTAssertTrue(engine.engineAU.schedule.infos.isEmpty)
        
        engine.output = rev
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(engine.engineAU.schedule.infos.count, 3)

        audio.audition()
    }
    
    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let dist = AppleDistortion(osc)
        
        engine.output = osc
        
        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        engine.output = dist
        
        audio.append(engine.render(duration: 1.0))

        audio.audition()
    }
    
    func testMixer() throws {
        
        let engine = AudioEngine2()
        
        let osc1 = TestOsc()
        let osc2 = TestOsc()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1, osc2])
        
        engine.output = mix
        
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))

        audio.audition()
    }
    
    func testMixerDynamic() throws {
        
        let engine = AudioEngine2()
        
        let osc1 = TestOsc()
        let osc2 = TestOsc()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1])
        
        engine.output = mix
        
        let audio = engine.startTest(totalDuration: 2.0)

        audio.append(engine.render(duration: 1.0))

        mix.addInput(osc2)
        
        audio.append(engine.render(duration: 1.0))

        audio.audition()
    }

    /// Test some number of changes so schedules are released.
    func testMultipleChanges() throws {

        let engine = AudioEngine2()

        let osc1 = TestOsc()
        let osc2 = TestOsc()

        osc1.frequency = 880

        engine.output = osc1

        let audio = engine.startTest(totalDuration: 10.0)

        for i in 0..<10 {
            audio.append(engine.render(duration: 1.0))
            engine.output = (i % 2 == 1) ? osc1 : osc2
        }

        audio.audition()
    }
}
