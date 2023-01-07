// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class TapNodeTests: XCTestCase {
    func quickieAmplitudes(left: [Float], right: [Float]) -> (Float, Float) {
        let leftAvg = left.reduce(0.0) { partialResult, current in
            partialResult + abs(current) / Float(left.count)
        }
        let rightAvg = right.reduce(0.0) { partialResult, current in
            partialResult + abs(current) / Float(left.count)
        }
        return (leftAvg, rightAvg)
    }

    func testTapNode() async throws {
        let engine = Engine()
        let noise = PlaygroundNoiseGenerator()
        noise.amplitude = 0.1
        let tapNode = TapNode(noise) { left, right in
            print(self.quickieAmplitudes(left: left, right: right))
        }
        engine.output = tapNode

        try engine.start()
        noise.play()
        sleep(1)
    }
}
