// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class ExpanderTests: XCTestCase {
    func testDefault() throws {
        try XCTSkipIf(true, "TODO This test gives different results on local machines from what CI does")
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Expander(sampler)
        sampler.play(url: URL.testAudio)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
