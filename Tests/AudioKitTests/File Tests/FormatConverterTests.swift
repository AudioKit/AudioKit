import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class FormatConverterTests: AudioFileTestCase {
    func testConversions() throws {
        var wave48k24bit: FormatConverter.Options {
            var options = FormatConverter.Options()
            options.sampleRate = 48000
            options.bitDepth = UInt32(24)
            options.format = "wav"
            options.eraseFile = true
            options.bitDepthRule = .lessThanOrEqual
            return options
        }
        var aiff44k16bit: FormatConverter.Options {
            var options = FormatConverter.Options()
            options.sampleRate = 44100
            options.bitDepth = UInt32(16)
            options.format = "aif"
            options.eraseFile = true
            options.bitDepthRule = .any
            return options
        }
        var caf96k32bit: FormatConverter.Options {
            var options = FormatConverter.Options()
            options.sampleRate = 96000
            options.bitDepth = UInt32(32)
            options.format = "caf"
            options.eraseFile = true
            options.bitDepthRule = .any
            return options
        }
        var m4a44k24bit: FormatConverter.Options {
            var options = FormatConverter.Options()
            options.sampleRate = 44100
            options.bitRate = 256000
            options.format = "m4a"
            options.eraseFile = true
            options.bitDepthRule = .any
            return options
        }

        let expectation1 = XCTestExpectation(description: "1")
        let expectation2 = XCTestExpectation(description: "2")
        let expectation3 = XCTestExpectation(description: "3")
        let expectation4 = XCTestExpectation(description: "4")

        var blocks = [expectation1]

        try convert(with: m4a44k24bit) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation1.fulfill()
        }

        blocks.append(expectation2)
        try convert(with: wave48k24bit) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation2.fulfill()
        }

        blocks.append(expectation3)
        try convert(with: aiff44k16bit) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation3.fulfill()
        }

        blocks.append(expectation4)
        try convert(with: caf96k32bit) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            expectation4.fulfill()
        }

        wait(for: blocks, timeout: 20)
    }

    private func convert(with options: FormatConverter.Options,
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

        guard let inputFile = generateTestFile() else {
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
