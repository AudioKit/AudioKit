// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TapTests: XCTestCase {

    func testTap2() throws {
        let engine = Engine()
        let noise = Noise()
        noise.amplitude = 0.1

        let expectation = XCTestExpectation(description: "tap callback called")

        let task = Task {
            for await (l,r) in Tap2(noise) {
                print("left.count: \(l.count), right.count: \(r.count)")
                print(detectAmplitudes([l, r]))
                expectation.fulfill()
            }
        }

        engine.output = noise

        try engine.start()
        wait(for: [expectation], timeout: 1.0)
        task.cancel()
    }

    func testTap2Dynamic() throws {
        let engine = Engine()
        let noise = Noise()
        noise.amplitude = 0.1

        let expectation = XCTestExpectation(description: "tap callback called")
        engine.output = noise

        try engine.start()

        // Add the tap after the engine is started. This should trigger
        // a recompile and the tap callback should still be called
        let task = Task {
            for await (l,r) in Tap2(noise) {
                print("left.count: \(l.count), right.count: \(r.count)")
                print(detectAmplitudes([l, r]))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
        task.cancel()
    }
}
