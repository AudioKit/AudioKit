// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class BaseTapTests: XCTestCase {

    func testBaseTapDeallocated() throws {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player

        var tap: BaseTap? = BaseTap(player, bufferSize: 1024)
        weak var weakTap = tap
        tap?.start()

        tap = nil

        XCTAssertNil(weakTap)
    }
}
