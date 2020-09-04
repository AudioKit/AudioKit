// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKit
import XCTest

// AKTestCase should be deleted, all that is need is the extension to XCTestCase below
// Too much magic, also made the tests unclear and harder to envision how useful
// they could be in one's own AudioKIt powered projects
class AKTestCase: XCTestCase {

    var duration = 0.1
    let engine = AKEngine()
    var input = AKOscillator()
    var buffer: AVAudioPCMBuffer!
    var afterStart: () -> Void = {}

    func AKTest(_ testName: String? = nil) {
        let localMD5 = try! engine.test(duration: duration, afterStart: afterStart)
        let name = testName ?? self.description
        XCTAssert(validatedMD5s[name] == localMD5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    override func setUp() {
        super.setUp()
        afterStart = { self.input.start() }
        AKDebugDSPSetActive(true)
        // This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // This method is called after the invocation of each test method in the class.
        engine.stop()
        super.tearDown()
        AKDebugDSPSetActive(false)
    }
}

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = self.description
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }

    func audition(_ buffer: AVAudioPCMBuffer) {
        let auditionEngine = AKEngine()
        let auditionPlayer = AKPlayer()
        auditionEngine.output = auditionPlayer
        try! auditionEngine.start()
        auditionPlayer.scheduleBuffer(buffer, at: nil)
        auditionPlayer.play()
        print("audition samples", buffer.frameCapacity)
        sleep(buffer.frameCapacity / 44100)
        auditionEngine.stop()
    }

}
