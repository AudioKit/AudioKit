// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class BaseTapTests: XCTestCase {
    func testBaseTapDeallocated() throws {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player

        var tap: BaseTap? = BaseTap(player, bufferSize: 1024, callbackQueue: .main)
        weak var weakTap = tap
        tap?.start()

        tap = nil

        XCTAssertNil(weakTap)
    }

    func testBufferSizeExceedingFrameCapacity() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player

        let tap: BaseTap = BaseTap(player, bufferSize: 176400, callbackQueue: .main)
        tap.start()
        _ = engine.startTest(totalDuration: 1.0)
        _ = engine.render(duration: 1.0)
  }
}
