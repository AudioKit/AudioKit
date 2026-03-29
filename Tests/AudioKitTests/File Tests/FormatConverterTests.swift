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
        options.format = .wav
        options.eraseFile = true
        options.bitDepthRule = .lessThanOrEqual

        XCTAssertThrowsError(try convert(with: options, input: stereoWAVE44k16Bit))
    }

    func testConvertAIFF44k16bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitDepth = UInt32(16)
        options.format = .aif
        options.eraseFile = true
        options.bitDepthRule = .any

        try convert(with: options)
    }

    func testConvertCAF96k32bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 96000
        options.bitDepth = UInt32(32)
        options.format = .caf
        options.eraseFile = true
        options.bitDepthRule = .any

        try convert(with: options)
    }

    func testConvertM4A24Bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 44100
        options.bitRate = 256000
        options.format = .m4a
        options.eraseFile = true
        options.bitDepthRule = .any

        try convert(with: options)
    }

    func testConvertMonoM4A24Bit() throws {
        var options = FormatConverter.Options()
        options.sampleRate = 48000
        options.bitRate = 320000
        options.format = .m4a
        options.eraseFile = true
        options.bitDepthRule = .any

        try convert(with: options, input: monoWAVE44k24Bit)
    }

    func testStereoToMonoMixesAllChannels() throws {
        // Convert existing stereo files to mono and verify the output contains
        // audible audio, not silence. Tests FormatConverter's channel mixing
        // for the fix in AudioKit/AudioKit#2900.
        let inputs: [(URL?, String)] = [
            (stereoAIFF44k32Bit, "AIFF 32-bit"),
            (stereoWAVE44k16Bit, "WAV 16-bit"),
        ]

        for (inputURL, label) in inputs {
            guard let inputURL = inputURL else {
                XCTFail("Missing test resource for \(label)")
                continue
            }

            let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent("_StereoMonoMix_\(label.replacingOccurrences(of: " ", with: "_"))")
            try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmp) }

            let outputURL = tmp.appendingPathComponent("mono.wav")

            var options = FormatConverter.Options()
            options.format = .wav
            options.sampleRate = 44100
            options.bitDepth = 16
            options.channels = 1
            options.eraseFile = true
            options.bitDepthRule = .any

            let expectation = XCTestExpectation(description: "Convert \(label) stereo to mono")
            let converter = FormatConverter(inputURL: inputURL, outputURL: outputURL, options: options)

            var conversionError: Error?
            converter.start { error in
                conversionError = error
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 30)
            XCTAssertNil(conversionError, "\(label) conversion failed: \(String(describing: conversionError))")

            let monoFile = try AVAudioFile(forReading: outputURL)
            XCTAssertEqual(monoFile.fileFormat.channelCount, 1, "\(label) output should be mono")
            XCTAssertGreaterThan(monoFile.length, 0, "\(label) output should not be empty")

            let readFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                           sampleRate: 44100,
                                           channels: 1,
                                           interleaved: false)!
            let monoBuffer = AVAudioPCMBuffer(pcmFormat: readFormat,
                                               frameCapacity: AVAudioFrameCount(monoFile.length))!
            try monoFile.read(into: monoBuffer)

            // Verify the output contains audible audio
            var maxAmplitude: Float = 0
            var rmsSum: Float = 0
            if let floatData = monoBuffer.floatChannelData {
                for i in 0 ..< Int(monoBuffer.frameLength) {
                    let sample = floatData[0][i]
                    maxAmplitude = max(maxAmplitude, abs(sample))
                    rmsSum += sample * sample
                }
            }
            let rms = sqrt(rmsSum / Float(monoBuffer.frameLength))

            XCTAssertGreaterThan(maxAmplitude, 0.01, "\(label) mono output should not be silent")
            XCTAssertGreaterThan(rms, 0.001, "\(label) mono output should have meaningful energy")
        }
    }

    func testStereoToMonoRightChannelPreserved() throws {
        // Create a stereo WAV with audio only on the right channel,
        // convert to mono, and verify the output is non-silent.
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("_StereoMonoTest")
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let sampleRate: Double = 44100
        let frameCount: AVAudioFrameCount = 44100 // 1 second
        guard let stereoFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                               sampleRate: sampleRate,
                                               channels: 2,
                                               interleaved: false) else {
            XCTFail("Failed to create stereo format")
            return
        }

        guard let stereoBuffer = AVAudioPCMBuffer(pcmFormat: stereoFormat, frameCapacity: frameCount) else {
            XCTFail("Failed to create stereo buffer")
            return
        }
        stereoBuffer.frameLength = frameCount

        // Fill: left channel silence, right channel with a 440 Hz sine
        if let floatData = stereoBuffer.floatChannelData {
            for i in 0 ..< Int(frameCount) {
                let sample = Float(sin(Double(i) * 2.0 * .pi * 440.0 / sampleRate) * 0.8)
                floatData[0][i] = 0      // left: silence
                floatData[1][i] = sample // right: sine
            }
        }

        let inputURL = tmp.appendingPathComponent("rightOnly.wav")
        let writeSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        // Scope the writer so it closes before FormatConverter opens the file
        do {
            let inputFile = try AVAudioFile(forWriting: inputURL,
                                            settings: writeSettings)
            try inputFile.write(from: stereoBuffer)
        }

        let outputURL = tmp.appendingPathComponent("mono.wav")

        var options = FormatConverter.Options()
        options.format = .wav
        options.sampleRate = sampleRate
        options.bitDepth = 16
        options.channels = 1
        options.eraseFile = true
        options.bitDepthRule = .any

        let expectation = XCTestExpectation(description: "Convert stereo to mono")
        let converter = FormatConverter(inputURL: inputURL, outputURL: outputURL, options: options)

        var conversionError: Error?
        converter.start { error in
            conversionError = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 30)
        XCTAssertNil(conversionError, "Conversion failed: \(conversionError!)")

        // Read the mono output and verify it contains non-silent audio
        let monoFile = try AVAudioFile(forReading: outputURL)
        XCTAssertEqual(monoFile.fileFormat.channelCount, 1)
        XCTAssertGreaterThan(monoFile.length, 0, "Output file should not be empty")

        let readFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                       sampleRate: sampleRate,
                                       channels: 1,
                                       interleaved: false)!
        let monoBuffer = AVAudioPCMBuffer(pcmFormat: readFormat,
                                           frameCapacity: AVAudioFrameCount(monoFile.length))!
        try monoFile.read(into: monoBuffer)

        // Check that the output has non-trivial amplitude (right channel was mixed in)
        var maxAmplitude: Float = 0
        if let floatData = monoBuffer.floatChannelData {
            for i in 0 ..< Int(monoBuffer.frameLength) {
                maxAmplitude = max(maxAmplitude, abs(floatData[0][i]))
            }
        }
        XCTAssertGreaterThan(maxAmplitude, 0.1, "Mono output should contain audio from the right channel")
    }

    // MARK: helpers

    private func convert(with options: FormatConverter.Options,
                         input: URL? = nil) throws
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

        wait(for: [expectation], timeout: 30)

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
