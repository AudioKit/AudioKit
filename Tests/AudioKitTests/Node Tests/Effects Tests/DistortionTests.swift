// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFAudio

class DistortionTests: XCTestCase {
    #if os(iOS)
    func testDefaultDistortion() {
        let engine3D = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine3D.output = AppleDistortion(input)
        let audio = engine3D.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine3D.render(duration: 1.0))
//        testMD5(audio)
    }
    #endif
}
