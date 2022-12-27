// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFAudio

class DistortionTests: XCTestCase {
    #if os(iOS)
    func testDefaultDistortion() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = AppleDistortion(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
//        testMD5(audio)
    }
    #endif
}
