// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

public extension AVAudioFile {
    /// Duration in seconds
    var duration: TimeInterval {
        Double(length) / fileFormat.sampleRate
    }

    /// returns the max level in the file as a Peak struct
    var peak: AVAudioPCMBuffer.Peak? {
        toAVAudioPCMBuffer()?.peak()
    }

    /// Convenience init to instantiate a file from an AVAudioPCMBuffer.
    convenience init(url: URL, fromBuffer buffer: AVAudioPCMBuffer) throws {
        try self.init(forWriting: url, settings: buffer.format.settings)

        // Write the buffer in file
        do {
            framePosition = 0
            try write(from: buffer)
        } catch let error as NSError {
            Log(error, type: .error)
            throw error
        }
    }

    /// converts to a 32 bit PCM buffer
    func toAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                            frameCapacity: AVAudioFrameCount(length)) else { return nil }

        guard let tmpBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                              frameCapacity: AVAudioFrameCount(length)) else { return nil }

        do {
            framePosition = 0
            while framePosition < length {
                try read(into: tmpBuffer)
                buffer.append(tmpBuffer)
            }
            Log("Created buffer with format", processingFormat)

        } catch let error as NSError {
            Log("Cannot read into buffer " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }

        return buffer
    }

    /// converts to Swift friendly Float array
    func toFloatChannelData() -> FloatChannelData? {
        guard let pcmBuffer = toAVAudioPCMBuffer(),
              let data = pcmBuffer.toFloatChannelData() else { return nil }
        return data
    }

    /// Will return a 32bit CAF file with the format of this buffer
    @discardableResult func extract(to outputURL: URL,
                                    from startTime: TimeInterval,
                                    to endTime: TimeInterval,
                                    fadeInTime: TimeInterval = 0,
                                    fadeOutTime: TimeInterval = 0) -> AVAudioFile?
    {
        guard let inputBuffer = toAVAudioPCMBuffer() else {
            Log("Error reading into input buffer", type: .error)
            return nil
        }

        guard var editedBuffer = inputBuffer.extract(from: startTime, to: endTime) else {
            Log("Failed to create edited buffer", type: .error)
            return nil
        }

        if fadeInTime != 0 || fadeOutTime != 0,
           let fadedBuffer = editedBuffer.fade(inTime: fadeInTime, outTime: fadeOutTime)
        {
            editedBuffer = fadedBuffer
        }

        var outputURL = outputURL
        if outputURL.pathExtension.lowercased() != "caf" {
            outputURL = outputURL.deletingPathExtension().appendingPathExtension("caf")
        }

        guard let outputFile = try? AVAudioFile(url: outputURL, fromBuffer: editedBuffer) else {
            Log("Failed to write new file at", outputURL, type: .error)
            return nil
        }
        return outputFile
    }

    /// - Returns: An extracted section of this file of the passed in conversion options
    func extract(to url: URL,
                 from startTime: TimeInterval,
                 to endTime: TimeInterval,
                 fadeInTime: TimeInterval = 0,
                 fadeOutTime: TimeInterval = 0,
                 options: FormatConverter.Options? = nil,
                 completionHandler: FormatConverter.FormatConverterCallback? = nil)
    {
        func createError(message: String, code: Int = 1) -> NSError {
            let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
            return NSError(domain: "io.audiokit.FormatConverter.error", code: code, userInfo: userInfo)
        }

        // if options are nil, create them to match the input file
        let options = options ?? FormatConverter.Options(audioFile: self)

        let format = options?.format ?? AudioFileFormat(rawValue: url.pathExtension) ?? .unknown
        let directory = url.deletingLastPathComponent()
        let filename = url.deletingPathExtension().lastPathComponent
        let tempFile = directory.appendingPathComponent(filename + "_temp").appendingPathExtension("caf")
        let outputURL = directory.appendingPathComponent(filename).appendingPathExtension(format.rawValue)

        // first print CAF file
        guard extract(to: tempFile,
                      from: startTime,
                      to: endTime,
                      fadeInTime: fadeInTime,
                      fadeOutTime: fadeOutTime) != nil
        else {
            completionHandler?(createError(message: "Failed to create new file"))
            return
        }

        // then convert to desired format here:
        guard FileManager.default.isReadableFile(atPath: tempFile.path) else {
            completionHandler?(createError(message: "File wasn't created correctly"))
            return
        }

        let converter = FormatConverter(inputURL: tempFile, outputURL: outputURL, options: options)
        converter.start { error in

            if let error = error {
                Log("Done, error", error, type: .error)
            }

            completionHandler?(error)

            do {
                // clean up temp file
                try FileManager.default.removeItem(at: tempFile)
            } catch {
                Log("Unable to remove temp file at", tempFile, type: .error)
            }
        }
    }
}

public extension AVURLAsset {
    /// Audio format for  the file in the URL asset
    var audioFormat: AVAudioFormat? {
        // pull the input format out of the audio file...
        if let source = try? AVAudioFile(forReading: url) {
            return source.fileFormat

            // if that fails it might be a video, so check the tracks for audio
        } else {
            let audioTracks = tracks.filter { $0.mediaType == .audio }

            guard !audioTracks.isEmpty else { return nil }

            let formatDescriptions = audioTracks.compactMap {
                $0.formatDescriptions as? [CMFormatDescription]
            }.reduce([], +)

            let audioFormats: [AVAudioFormat] = formatDescriptions.compactMap {
                AVAudioFormat(cmAudioFormatDescription: $0)
            }
            return audioFormats.first
        }
    }
}
