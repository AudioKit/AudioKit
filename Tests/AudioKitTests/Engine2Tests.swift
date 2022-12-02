// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class Engine2Tests: XCTestCase {
    
    func testBasic() throws {
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        
        XCTAssertTrue(engine.engineAU.execList.isEmpty)
        
        engine.output = osc
        
        XCTAssertEqual(engine.engineAU.execList.count, 1)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
    
    // Getting kAudioUnitErr_NoConnection
    func testEffect() throws {
        
        let engine = AudioEngine2()
        
        let osc = TestOsc()
        let fx = AppleDistortion(osc)
        
        XCTAssertTrue(engine.engineAU.execList.isEmpty)
        
        engine.output = fx
        
        XCTAssertEqual(engine.engineAU.execList.count, 2)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
}
