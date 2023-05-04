// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TapTests: XCTestCase {

    func testTap() async throws {

        let framesReceived = XCTestExpectation(description: "received audio frames")

        let engine = Engine()
        let noise = Noise()
        noise.amplitude = 0.1

        let tap = Tap(noise) { l,r in
            print("left.count: \(l.count), right.count: \(r.count)")
            print(detectAmplitudes([l, r]))
            framesReceived.fulfill()
        }

        engine.output = tap

        try engine.start()
        sleep(1)
        engine.stop()
    }

    func testTap2() throws {

        let framesReceived = XCTestExpectation(description: "received audio frames")
        let taskFinished = XCTestExpectation(description: "finished tap task")

        let scope = {
            let engine = Engine()
            let noise = Noise()
            noise.amplitude = 0.1

            let tap = Tap2(noise)

            Task {
                for await (l,r) in tap {
                    print("left.count: \(l.count), right.count: \(r.count)")
                    print(detectAmplitudes([l, r]))
                    framesReceived.fulfill()
                }
                print("task finished")
                taskFinished.fulfill()
            }

            engine.output = noise

            try engine.start()
            self.wait(for: [framesReceived], timeout: 1.0)
            engine.stop()
        }

        try scope()

        XCTAssertEqual(Noise.instanceCount.load(ordering: .relaxed), 0)
        wait(for: [taskFinished], timeout: 1.0)
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
            print("started tap task")
            for await (l,r) in Tap2(noise) {
                print("left.count: \(l.count), right.count: \(r.count)")
                print(detectAmplitudes([l, r]))
                expectation.fulfill()
            }
            print("ending tap task")
        }

        wait(for: [expectation], timeout: 1.0)
        task.cancel()
    }
}
