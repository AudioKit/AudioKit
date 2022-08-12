// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class RawDataTapTests: XCTestCase {

    func testRawDataTap() async throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        let _ = await RawDataTap2(osc, bufferSize: 1024) { _ in
            print("data!")
        }

        osc.start()
        try engine.start()

        sleep(10)
    }

}
