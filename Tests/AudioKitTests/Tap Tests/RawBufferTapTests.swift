// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFoundation

final class RawBufferTapTests: XCTestCase {

    func testRawBufferTap() throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator2()
        let mixer = Mixer(osc)
        mixer.volume = 0
        engine.output = mixer

        let dataExpectation = XCTestExpectation(description: "dataExpectation")
        var allBuffers: [(AVAudioPCMBuffer, AVAudioTime)] = []
        let tap = RawBufferTap(osc) { buffer, time in
            dataExpectation.fulfill()
            allBuffers.append((buffer, time))
        }

        tap.start()
        osc.start()
        try engine.start()

        wait(for: [dataExpectation], timeout: 1)

        XCTAssertGreaterThan(allBuffers.count, 0)
    }

}
