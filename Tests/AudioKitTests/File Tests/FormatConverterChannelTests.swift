import AudioKit
import AVFoundation
import XCTest

/// Tests for FormatConverter stereo-to-mono channel mixing (GitHub #2900)
class FormatConverterChannelTests: XCTestCase {
    let sampleRate: Double = 44100
    let frameCount: AVAudioFrameCount = 44100 // 1 second

    // MARK: - Tests

    /// Verifies that converting a stereo file with audio only in the RIGHT channel
    /// to mono produces non-silent output. This is the core bug from issue #2900.
    func testStereoToMonoPreservesRightChannel() async throws {
        let stereoBuffer = createStereoBuffer(leftValue: 0.0, rightValue: 0.5)
        let inputURL = try writeTempFile(buffer: stereoBuffer, name: "rightOnly")

        let monoBuffer = try await convertToMono(inputURL: inputURL)

        XCTAssertEqual(monoBuffer.format.channelCount, 1, "Output should be mono")
        XCTAssertGreaterThan(monoBuffer.frameLength, 0, "Output should have frames")

        let monoData = monoBuffer.floatChannelData![0]
        let hasNonZeroSamples = (0..<Int(monoBuffer.frameLength)).contains { monoData[$0] != 0 }
        XCTAssertTrue(hasNonZeroSamples, "Mono output should contain audio from the right channel")
    }

    /// Verifies that converting a stereo file with audio only in the LEFT channel
    /// to mono also produces non-silent output.
    func testStereoToMonoPreservesLeftChannel() async throws {
        let stereoBuffer = createStereoBuffer(leftValue: 0.5, rightValue: 0.0)
        let inputURL = try writeTempFile(buffer: stereoBuffer, name: "leftOnly")

        let monoBuffer = try await convertToMono(inputURL: inputURL)

        XCTAssertEqual(monoBuffer.format.channelCount, 1)

        let monoData = monoBuffer.floatChannelData![0]
        let hasNonZeroSamples = (0..<Int(monoBuffer.frameLength)).contains { monoData[$0] != 0 }
        XCTAssertTrue(hasNonZeroSamples, "Mono output should contain audio from the left channel")
    }

    /// Verifies that both channels are summed when converting stereo to mono.
    /// Left=0.25 and Right=0.25 should produce mono samples of 0.5 (sum of both).
    func testStereoToMonoMixesBothChannels() async throws {
        let stereoBuffer = createStereoBuffer(leftValue: 0.25, rightValue: 0.25)
        let inputURL = try writeTempFile(buffer: stereoBuffer, name: "bothChannels")

        let monoBuffer = try await convertToMono(inputURL: inputURL)

        XCTAssertEqual(monoBuffer.format.channelCount, 1)

        let monoData = monoBuffer.floatChannelData![0]
        // The mixed mono value should be approximately 0.5 (0.25 + 0.25)
        let sampleValue = monoData[Int(monoBuffer.frameLength) / 2]
        XCTAssertEqual(sampleValue, 0.5, accuracy: 0.01,
                       "Mono output should be the sum of both channels")
    }

    // MARK: - Helpers

    private func createStereoBuffer(leftValue: Float, rightValue: Float) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<Int(frameCount) {
            left[i] = leftValue
            right[i] = rightValue
        }
        return buffer
    }

    private func writeTempFile(buffer: AVAudioPCMBuffer, name: String) throws -> URL {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("FormatConverterChannelTests")
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)

        let url = tmp.appendingPathComponent("\(name).wav")
        try? FileManager.default.removeItem(at: url)

        let file = try AVAudioFile(forWriting: url,
                                   settings: buffer.format.settings)
        try file.write(from: buffer)
        return url
    }

    private func convertToMono(inputURL: URL) async throws -> AVAudioPCMBuffer {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("FormatConverterChannelTests")
        let outputURL = tmp.appendingPathComponent("output_mono.wav")
        try? FileManager.default.removeItem(at: outputURL)

        defer {
            try? FileManager.default.removeItem(at: tmp)
        }

        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = sampleRate
        options.bitDepth = 16
        options.channels = 1
        options.eraseFile = true
        options.bitDepthRule = .any

        let converter = FormatConverter(inputURL: inputURL, outputURL: outputURL, options: options)

        #if Swift6
        try await converter.start()
        #else
        let expectation = XCTestExpectation(description: "conversion")
        var conversionError: Error?

        converter.start { error in
            conversionError = error
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 30)

        if let error = conversionError {
            throw error
        }
        #endif

        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            throw NSError(domain: "FormatConverterChannelTests", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Output file missing"])
        }

        let outputFile = try AVAudioFile(forReading: outputURL)

        // Read into a float format for easy inspection
        let processingFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                            frameCapacity: AVAudioFrameCount(outputFile.length))!
        try outputFile.read(into: outputBuffer)
        return outputBuffer
    }
}
