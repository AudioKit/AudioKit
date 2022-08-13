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

}
