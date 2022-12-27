// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class BaseTapTests: XCTestCase {
    func testBaseTapDeallocated() throws {
        let engine = AudioEngine()
        let player = AudioPlayer(url: URL.testAudio)!
        engine.output = player

        var tap: BaseTap? = BaseTap(player, bufferSize: 1024)
        weak var weakTap = tap
        tap?.start()

        tap = nil

        XCTAssertNil(weakTap)
    }

    func testBufferSizeExceedingFrameCapacity() {
        let engine = AudioEngine()
        let player = AudioPlayer(url: URL.testAudio)!
        engine.output = player

        let tap: BaseTap = BaseTap(player, bufferSize: 176400)
        tap.start()
        _ = engine.startTest(totalDuration: 1.0)
        _ = engine.render(duration: 1.0)
  }
}
