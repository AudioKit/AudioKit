// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class AmplitudeTapTests: XCTestCase {

    func testTapDoesntDeadlockOnStop() throws {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player
        let tap = AmplitudeTap(player)

        _ = engine.startTest(totalDuration: 1)
        tap.start()
        _ = engine.render(duration: 1)
        tap.stop()

        XCTAssertFalse(tap.isStarted)
    }
}
