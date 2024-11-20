import AudioKit
import AVFoundation
import Foundation
import XCTest

class AVAudioPCMBufferReduceToBucketsTests: XCTestCase {
    let sampleRate: Double = 44100
    lazy var capacity = UInt32(sampleRate)
    lazy var format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
    lazy var buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)!
    lazy var data = buffer.floatChannelData!

    func testOneSamplePerBucket() {
        for index in 0..<capacity {
            data[0][Int(index)] = 1
        }
        buffer.frameLength = capacity

        let buckets = buffer.reduce(bucketCount: 44100)

        XCTAssertEqual(buckets.0.count, 44100)
        XCTAssertTrue(buckets.0.allSatisfy { $0 == 1 })
    }

    func testTwoSamplesPerBucketHigherSampleReturned() {
        for index in 0..<Int(capacity) {
            data[0][index] = index.isMultiple(of: 2) ? 1 : 0.5
        }
        buffer.frameLength = capacity

        let buckets = buffer.reduce(bucketCount: 22050)

        XCTAssertEqual(buckets.0.count, 22050)
        XCTAssertTrue(buckets.0.allSatisfy { $0 == 1 })
    }

    func testTwoSamplesPerBucketHigherAbsoluteSampleReturned() {
        for index in 0..<Int(capacity) {
            data[0][index] = index.isMultiple(of: 2) ? -1 : 0.5
        }
        buffer.frameLength = capacity

        let buckets = buffer.reduce(bucketCount: 22050)

        XCTAssertEqual(buckets.0.count, 22050)
        XCTAssertTrue(buckets.0.allSatisfy { $0 == -1 })
    }

    func testLessThenOneSamplePerBucketFallbacksToOneSamplePerBucket() {
        for index in 0..<Int(capacity) {
            data[0][index] = 1
        }
        buffer.frameLength = capacity

        let buckets = buffer.reduce(bucketCount: 44102)

        XCTAssertEqual(buckets.0.count, 44102)
        XCTAssertTrue(buckets.0[..<44100].allSatisfy { $0 == 1 })
        XCTAssertEqual(buckets.0[44100..<44102], [0, 0])
    }

    func testAbsoluteMax() {
        for index in 0..<Int(capacity) {
            data[0][index] = Float(index + 1)
        }
        buffer.frameLength = capacity

        let buckets = buffer.reduce(bucketCount: 44102)

        XCTAssertEqual(buckets.1, 44100)
    }
}
