// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import XCTest
import AudioKit
import AVFoundation

final class RawBufferTapTests: XCTestCase {

    func testRawBufferTap() throws {

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        let dataExpectation = XCTestExpectation(description: "dataExpectation")
        var allBuffers: [(AVAudioPCMBuffer, AVAudioTime)] = []
        let tap = RawBufferTap(osc, callbackQueue: .main) { buffer, time in
            dataExpectation.fulfill()
            allBuffers.append((buffer, time))
        }

        tap.start()
        osc.start()
        try engine.start()

        wait(for: [dataExpectation], timeout: 1)

        XCTAssertGreaterThan(allBuffers.count, 0)
    }

    func testRawBufferTapCount() throws {
        let duration = 1.5
        let bufferSize = 1024
        let rounding = 0.9

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        engine.output = osc

        let durationExpectation = XCTestExpectation(description: "durationExpectation")
        var allBuffers: [(AVAudioPCMBuffer, AVAudioTime)] = []
        let tap = RawBufferTap(osc, bufferSize: UInt32(bufferSize), callbackQueue: .main) { buffer, time in
            allBuffers.append((buffer, time))
        }

        tap.start()
        osc.start()
        try engine.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            durationExpectation.fulfill()
        }
        wait(for: [durationExpectation], timeout: duration + 0.5)

        XCTAssertGreaterThan(allBuffers.count, Int(Settings.sampleRate / Double(bufferSize) * duration * rounding))
    }

}
