// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFAudio

class DistortionTests: XCTestCase {
    #if os(iOS)
    func testDefaultDistortion() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine.output = AppleDistortion(input)
        let audio = engine.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine.render(duration: 1.0))
//        testMD5(audio)
    }
    #endif
}
