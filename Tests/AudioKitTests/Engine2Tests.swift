// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class Engine2Tests: XCTestCase {
    
    func testBasic() throws {
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        
        XCTAssertTrue(engine.schedule.schedule.isEmpty)
        
        engine.output = osc
        
        XCTAssertEqual(engine.schedule.schedule.count, 1)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
    
    func testEffect() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let fx = AppleDistortion(osc)
        
        XCTAssertTrue(engine.schedule.schedule.isEmpty)
        
        engine.output = fx
        
        XCTAssertEqual(engine.schedule.schedule.count, 2)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
    
    func testTwoEffects() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let dist = AppleDistortion(osc)
        let rev = Reverb(dist)
        
        XCTAssertTrue(engine.schedule.schedule.isEmpty)
        
        engine.output = rev
        
        XCTAssertEqual(engine.schedule.schedule.count, 3)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
    
    /// Test changing the output chain on the fly.
    func testDynamicChange() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let dist = AppleDistortion(osc)
        
        engine.output = osc
        
        try engine.start()
        
        sleep(2)
        
        engine.output = dist
        
        sleep(2)
        
        engine.stop()
    }
    
    func testMixer() throws {
        
        let engine = AudioEngine2()
        
        let osc1 = TestOsc()
        let osc2 = TestOsc()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1, osc2])
        
        engine.output = mix
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
    
    func testMixerDynamic() throws {
        
        let engine = AudioEngine2()
        
        let osc1 = TestOsc()
        let osc2 = TestOsc()
        osc2.frequency = 466.16 // dissonance, so we can really hear it
        
        let mix = Mixer([osc1])
        
        engine.output = mix
        
        try engine.start()
        
        sleep(2)
        
        mix.addInput(osc2)
        
        sleep(2)
        
        engine.stop()
    }
}
