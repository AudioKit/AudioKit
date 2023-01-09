// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class TapNodeTests: XCTestCase {

    func testTapNode() async throws {
        let engine = Engine()
        let noise = PlaygroundNoiseGenerator()
        noise.amplitude = 0.1
        let tapNode = Tap(noise, bufferSize: 256) { left, right in
            print("left.count: \(left.count), right.count: \(right.count)")
            print(detectAmplitudes([left, right]))
        }
        engine.output = tapNode

        try engine.start()
        noise.play()
        sleep(1)
    }
}
