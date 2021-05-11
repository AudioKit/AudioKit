// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class MetalBarTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let metalBar = MetalBar()
        engine.output = metalBar
        let audio = engine.startTest(totalDuration: 2.0)
        metalBar.trigger()
        audio.append(engine.render(duration: 1.0))
        metalBar.trigger()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
