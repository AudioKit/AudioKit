// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class TapNodeTests: XCTestCase {

    func testTapNode() async throws {
        let engine = Engine()
        let osc = PlaygroundOscillator()
        osc.amplitude = 0.1
        let tapNode = TapNode(osc) { left, right in
            print(left.count, right.count)
        }
        engine.output = tapNode

        try engine.start()
        osc.play()
        sleep(1)
    }
}
