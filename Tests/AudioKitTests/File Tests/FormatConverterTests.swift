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

    func testbitDepthRule() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 48000
        options.bitDepth = UInt32(24)
        options.format = "wav"
        options.eraseFile = true
        options.bitDepthRule = .lessThanOrEqual

        let expectation = XCTestExpectation(description: String(describing: options))

        try convert(with: options, input: stereoWAVE44k16Bit) { error in
            if let error = error {
                Log(error.localizedDescription)
            }
            // should be not nil as the target bitDepth is higher than the source
            XCTAssertNotNil(error)

            expectation.fulfill()
        }
    }

    func testConvertAIFF44k16bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitDepth = UInt32(16)
        options.format = "aif"
        options.eraseFile = true
        options.bitDepthRule = .any

        let expectation = XCTestExpectation(description: String(describing: options))
        try convert(with: options) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
    }

    func testConvertCAF96k32bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 96000
        options.bitDepth = UInt32(32)
        options.format = "caf"
        options.eraseFile = true
        options.bitDepthRule = .any

        let expectation = XCTestExpectation(description: String(describing: options))
        try convert(with: options) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
    }

    func testConvertM4A24Bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitRate = 256000
        options.format = "m4a"
        options.eraseFile = true
        options.bitDepthRule = .any

        let expectation = XCTestExpectation(description: String(describing: options))
        try convert(with: options) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
    }

    func testConvertMonoM4A24Bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 48000
        options.bitRate = 320000
        options.format = "m4a"
        options.eraseFile = true
        options.bitDepthRule = .any

        let expectation = XCTestExpectation(description: String(describing: options))
        try convert(with: options, input: monoWAVE44k24Bit) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
    }

    // MARK: helpers

    private func convert(with options: FormatConverter.Options,
                         input: URL? = nil,
                         completionHandler: FormatConverter.FormatConverterCallback) throws {
        guard let format = options.format,
              let sampleRate = options.sampleRate else {
            throw createError(message: "Invalid Options")
        }

        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("_ConversionTests")

        if !FileManager.default.fileExists(atPath: tmp.path) {
            try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        guard let inputFile = input ?? stereoAIFF44k32Bit else {
            let error = createError(message: "Failed to generate file")
            completionHandler(error)
            return
        }

        let name = inputFile.deletingPathExtension().lastPathComponent
        let outputURL = tmp.appendingPathComponent(name).appendingPathExtension(format)

        defer {
            // Log("🗑 Deleting:", tmp.lastPathComponent)
            try? FileManager.default.removeItem(at: tmp)
        }

        let expectation = XCTestExpectation(description: outputURL.path)
        let converter = FormatConverter(inputURL: inputFile, outputURL: outputURL, options: options)

        converter.start { error in
            if let error = error {
                Log(error, type: .error)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 9)

        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            let error = createError(message: "File is missing at \(outputURL.path)")
            completionHandler(error)
            return
        }

        let avFile = try AVAudioFile(forReading: outputURL)
        let streamDescription: AudioStreamBasicDescription = avFile.fileFormat.streamDescription.pointee

        guard avFile.fileFormat.sampleRate == sampleRate else {
            let error = createError(message: "Incorrect Sample Rate of \(avFile.fileFormat.sampleRate), should be \(sampleRate)")
            completionHandler(error)
            return
        }

        guard outputURL.pathExtension == format else {
            let error = createError(message: "Incorrect format of \(outputURL.pathExtension), should be \(format)")
            completionHandler(error)
            return
        }

        if streamDescription.mFormatID == kAudioFormatLinearPCM, let bitDepth = options.bitDepth {
            guard streamDescription.mBitsPerChannel == bitDepth else {
                let error = createError(message: "Incorrect bitDepth of \(streamDescription.mBitsPerChannel), should be \(bitDepth)")
                completionHandler(error)
                return
            }
        }

        completionHandler(nil)
    }
}
