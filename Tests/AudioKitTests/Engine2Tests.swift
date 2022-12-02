// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
@testable import AudioKit
import AVFoundation
import XCTest

class Engine2Tests: XCTestCase {
    
    func testBasic() throws {
        let engine = AudioEngine2()
        
        let osc = PlaygroundOscillator()
        
        XCTAssertTrue(engine.engineAU.execList.isEmpty)
        
        engine.output = osc
        
        XCTAssertEqual(engine.engineAU.execList.count, 1)
        
        try engine.start()
        
        sleep(2)
        
        engine.stop()
    }
}
