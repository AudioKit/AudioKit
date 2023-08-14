// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TapTests: AKTestCase {
    var engine: AudioEngine!
    var framesReceived: XCTestExpectation!

    override func setUp() async throws {
        engine = AudioEngine()
        framesReceived = XCTestExpectation(description: "received audio frames")
    }

    override func tearDown() {
        engine.stop()
        engine = nil
        super.tearDown()
    }

    func testCorrectDataPulled() throws {
        let oscillator = TestOscillator(waveform: .init([1]))

        let tap = Tap(oscillator) { (left, right) in
            XCTAssertTrue(left.allSatisfy { $0 == 1 })
            XCTAssertTrue(right.allSatisfy { $0 == 1 })
            self.framesReceived.fulfill()
        }

        engine.output = oscillator

        try engine.start()
        self.wait(for: [framesReceived], timeout: 1.0)
        XCTAssertNotNil(tap) // just to keep the tap alive
    }


    func testCorrectNumberOfFramesPulled() throws {
        let oscillator = TestOscillator(waveform: .init([1]))

        let tap = Tap(oscillator, bufferSize: 2048) { (left, right) in
            XCTAssertEqual(left.count, 2048)
            XCTAssertEqual(right.count, 2048)
            self.framesReceived.fulfill()
        }

        engine.output = oscillator

        try engine.start()
        self.wait(for: [framesReceived], timeout: 1.0)
        XCTAssertNotNil(tap) // just to keep the tap alive
    }

    func testAddingTapAfterStartingEngineTriggersCallback() throws {
        let oscillator = TestOscillator(waveform: .init([1]))

        engine.output = oscillator

        try engine.start()

        let tap = Tap(oscillator) { _, _ in
            self.framesReceived.fulfill()
        }

        wait(for: [framesReceived], timeout: 1.0)
        XCTAssertNotNil(tap) // just to keep the tap alive
    }
}
