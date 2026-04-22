import AudioKit
import AVFoundation
import XCTest

class FormatConverterTests: AudioFileTestCase {
    var stereoAIFF44k32Bit: URL? {
        Bundle.module.url(forResource: "chromaticScale-5", withExtension: "aiff", subdirectory: "TestResources")
    }

    var monoWAVE44k24Bit: URL? {
        Bundle.module.url(forResource: "dish", withExtension: "wav", subdirectory: "TestResources")
    }

    var stereoWAVE44k16Bit: URL? {
        Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")
    }

    func testbitDepthRule() async throws {
        var options = FormatConverter.Options()
        options.sampleRate = 48000
        options.bitDepth = UInt32(24)
        options.format = .wav
        options.eraseFile = true
        options.bitDepthRule = .lessThanOrEqual

        do {
            try await convert(with: options, input: stereoWAVE44k16Bit)
            XCTFail("Expected error for bit depth rule violation")
        } catch {
            // expected
        }
    }

    func testConvertAIFF44k16bit() async throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitDepth = UInt32(16)
        options.format = .aif
        options.eraseFile = true
        options.bitDepthRule = .any

        try await convert(with: options)
    }

    func testConvertCAF96k32bit() async throws {
        var options = FormatConverter.Options()
        options.sampleRate = 96000
        options.bitDepth = UInt32(32)
        options.format = .caf
        options.eraseFile = true
        options.bitDepthRule = .any

        try await convert(with: options)
    }

    func testConvertM4A24Bit() async throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitRate = 256000
        options.format = .m4a
        options.eraseFile = true
        options.bitDepthRule = .any

        try await convert(with: options)
    }

    func testConvertMonoM4A24Bit() async throws {
        var options = FormatConverter.Options()
        options.sampleRate = 48000
        options.bitRate = 320000
        options.format = .m4a
        options.eraseFile = true
        options.bitDepthRule = .any

        try await convert(with: options, input: monoWAVE44k24Bit)
    }

    // MARK: helpers

    private func convert(with options: FormatConverter.Options,
                         input: URL? = nil) async throws
    {
        guard let format = options.format,
              let sampleRate = options.sampleRate
        else {
            throw createError(message: "Invalid Options")
        }

        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("_ConversionTests")

        if !FileManager.default.fileExists(atPath: tmp.path) {
            try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        guard let inputFile = input ?? stereoAIFF44k32Bit else {
            throw createError(message: "Failed to generate file")
        }

        let name = inputFile.deletingPathExtension().lastPathComponent
        let outputURL = tmp.appendingPathComponent(name).appendingPathExtension(format.rawValue)

        defer {
            try? FileManager.default.removeItem(at: tmp)
        }

        let converter = FormatConverter(inputURL: inputFile, outputURL: outputURL, options: options)

        #if Swift6
        try await converter.start()
        #else
        let expectation = XCTestExpectation(description: outputURL.path)

        converter.start { error in
            if let error = error {
                Log(error, type: .error)
            }
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 30)
        #endif

        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            throw createError(message: "File is missing at \(outputURL.path)")
        }

        let avFile = try AVAudioFile(forReading: outputURL)
        let streamDescription: AudioStreamBasicDescription = avFile.fileFormat.streamDescription.pointee

        guard avFile.fileFormat.sampleRate == sampleRate else {
            throw createError(message: "Incorrect Sample Rate of \(avFile.fileFormat.sampleRate), should be \(sampleRate)")
        }

        guard outputURL.pathExtension == format.rawValue else {
            throw createError(message: "Incorrect format of \(outputURL.pathExtension), should be \(format)")
        }

        if streamDescription.mFormatID == kAudioFormatLinearPCM, let bitDepth = options.bitDepth {
            guard streamDescription.mBitsPerChannel == bitDepth else {
                throw createError(message: "Incorrect bitDepth of \(streamDescription.mBitsPerChannel), should be \(bitDepth)")
            }
        }
    }
}
