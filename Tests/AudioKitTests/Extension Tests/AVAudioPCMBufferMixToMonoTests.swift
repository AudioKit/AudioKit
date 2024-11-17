import AudioKit
import AVFoundation
import Foundation
import XCTest

class AVAudioPCMBufferMixToMonoTests: XCTestCase {
    let sampleRate: Double = 44100
    lazy var capacity = 10 * UInt32(sampleRate)
    lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
    lazy var buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)!
    lazy var data = buffer.floatChannelData!

    func testMixToMonoCancellation() {
        for index in 0..<capacity {
            data[0][Int(index)] = -1
            data[1][Int(index)] = 1
        }
        buffer.frameLength = capacity

        let mono = buffer.mixToMono()

        XCTAssertEqual(mono.format.channelCount, 1)
        XCTAssertEqual(mono.frameCapacity, capacity)
        XCTAssertEqual(mono.frameLength, capacity)

        XCTAssertTrue(mono.toFloatChannelData()![0].allSatisfy { $0 == 0 })
    }

    func testMixToMonoDouble() {
        for index in 0..<capacity {
            data[0][Int(index)] = 1
            data[1][Int(index)] = 1
        }
        buffer.frameLength = capacity

        let mono = buffer.mixToMono()

        XCTAssertEqual(mono.format.channelCount, 1)
        XCTAssertEqual(mono.frameCapacity, capacity)
        XCTAssertEqual(mono.frameLength, capacity)

        XCTAssertTrue(mono.toFloatChannelData()![0].allSatisfy { $0 == 2 })
    }
}
