// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TapTests: AKTestCase {
    func testTapNode() async throws {

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
        // let taskFinished = XCTestExpectation(description: "finished tap task")

        let scope = {
            let engine = Engine()
            let noise = Noise()
            noise.amplitude = 0.1

            let tap: Tap2? = Tap2(noise) { (l, r) in
                print("left.count: \(l.count), right.count: \(r.count)")
                print(detectAmplitudes([l, r]))
                framesReceived.fulfill()
            }

            engine.output = noise

            try engine.start()
            self.wait(for: [framesReceived], timeout: 1.0)
            engine.stop()
            XCTAssertNotNil(tap) // just to keep the tap alive
        }

        try scope()
    }

    func testTap2Dynamic() throws {
        let engine = Engine()
        let noise = Noise()
        noise.amplitude = 0.1

        let framesReceived = XCTestExpectation(description: "received audio frames")
        engine.output = noise

        try engine.start()

        // Add the tap after the engine is started. This should trigger
        // a recompile and the tap callback should still be called
        let tap: Tap2? = Tap2(noise) { l,r in
            print("left.count: \(l.count), right.count: \(r.count)")
            print(detectAmplitudes([l, r]))
            framesReceived.fulfill()
        }

        wait(for: [framesReceived], timeout: 1.0)
        XCTAssertNotNil(tap) // just to keep the tap alive
    }
}
