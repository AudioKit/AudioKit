// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKit
import XCTest

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
