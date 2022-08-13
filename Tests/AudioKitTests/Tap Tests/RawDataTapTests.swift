// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class RawDataTapTests: XCTestCase {

    func testRawDataTap() throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        let dataExpectation = XCTestExpectation(description: "dataExpectation")
        var allData: [Float] = []
        let tap = RawDataTap2(osc) { data in
            dataExpectation.fulfill()
            allData = allData + data
        }

        osc.install(tap: tap, bufferSize: 1024)

        osc.amplitude = 0
        osc.start()
        try engine.start()

        wait(for: [dataExpectation], timeout: 1)

        XCTAssertGreaterThan(allData.count, 0)
    }

    func testRawDataTapTask() throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        osc.amplitude = 0
        osc.start()
        try engine.start()

        Task {
            let dataExpectation = XCTestExpectation(description: "dataExpectation")
            var allData: [Float] = []
            let tap = RawDataTap2(osc) { data in
                dataExpectation.fulfill()
                allData = allData + data
                print("Tap handler called!")
            }

            osc.install(tap: tap, bufferSize: 1024)
        }

        // Lock up the main thread instead of servicing the runloop.
        // This demonstrates that we can use a Tap safely on a background
        // thread.
        // XXX: I'm not sure how to assert that the tap was actually called.
        sleep(1)

    }

}
