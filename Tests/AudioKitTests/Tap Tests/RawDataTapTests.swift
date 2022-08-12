// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit

class RawDataTapTests: XCTestCase {

    func testRawDataTap() throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        let dataExpectation = XCTestExpectation(description: "dataExpectation")
        let tap = RawDataTap2(osc) { _ in
            dataExpectation.fulfill()
        }

        install(tap: tap, on: osc, bufferSize: 1024)

        osc.amplitude = 0
        osc.start()
        try engine.start()

        wait(for: [dataExpectation], timeout: 1)
    }

}
