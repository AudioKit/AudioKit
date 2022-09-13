// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DynamicsProcessorTests: XCTestCase {
    func testDefault() throws {
        try XCTSkipIf(true, "TODO This test gives different results on local machines from what CI does")
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine.output = DynamicsProcessor(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
