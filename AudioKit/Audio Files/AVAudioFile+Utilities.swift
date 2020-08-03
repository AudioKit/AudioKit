// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate

extension AVAudioFile {
    /// Duration in seconds
    public var duration: TimeInterval {
        Double(length) / fileFormat.sampleRate
    }

    /// returns the max level in the file as a Peak struct
    public var peak: AVAudioPCMBuffer.Peak? {
        toAVAudioPCMBuffer()?.peak()
    }
}

extension AVAudioFile {
    /// Convenience init to instantiate a file from an AVAudioPCMBuffer.
    public convenience init(url: URL, fromBuffer buffer: AVAudioPCMBuffer) throws {
        try self.init(forWriting: url, settings: buffer.format.settings)

        // Write the buffer in file
        do {
            try self.write(from: buffer)
        } catch let error as NSError {
            AKLog(error, type: .error)
            throw error
        }
    }
}

extension AVAudioFile {
    /// converts to a 32 bit PCM buffer
    public func toAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat,
                                            frameCapacity: AVAudioFrameCount(self.length)) else { return nil }

        do {
            // reopen file for safety
            if let readFile = try? AVAudioFile(forReading: url) {
                try readFile.read(into: buffer)
                AKLog("Created buffer with format", self.processingFormat)
            }

        } catch let error as NSError {
            AKLog("Cannot read into buffer " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }

        return buffer
    }

    /// converts to Swift friendly Float array
    public func toFloatChannelData() -> FloatChannelData? {
        guard let pcmBuffer = self.toAVAudioPCMBuffer(),
            let data = pcmBuffer.toFloatChannelData() else { return nil }
        return data
    }

    /// Will return a 32bit CAF file of the sampleRate of this buffer
    @discardableResult public func extract(to outputURL: URL,
                                           from startTime: TimeInterval,
                                           to endTime: TimeInterval,
                                           fadeInTime: TimeInterval = 0,
                                           fadeOutTime: TimeInterval = 0) -> AVAudioFile? {
        guard let inputBuffer = toAVAudioPCMBuffer() else {
            AKLog("Error reading into input buffer", type: .error)
            return nil
        }

        guard var editedBuffer = inputBuffer.extract(from: startTime, to: endTime) else {
            AKLog("Failed to create edited buffer", type: .error)
            return nil
        }

        if fadeInTime != 0 || fadeOutTime != 0,
            let fadedBuffer = editedBuffer.fade(inTime: fadeInTime, outTime: fadeOutTime) {
            editedBuffer = fadedBuffer
        }

        var outputURL = outputURL
        if outputURL.pathExtension.lowercased() != "caf" {
            outputURL = outputURL.deletingPathExtension().appendingPathExtension("caf")
        }

        guard let outputFile = try? AVAudioFile(url: outputURL, fromBuffer: editedBuffer) else {
            AKLog("Failed to write new file at", outputURL, type: .error)
            return nil
        }

        return outputFile
    }

    /// - Returns: An extracted section of this file of the passed in conversion options
    public func extract(to url: URL,
                        from startTime: TimeInterval,
                        to endTime: TimeInterval,
                        options: AKConverter.Options? = nil,
                        fadeInTime: TimeInterval = 0,
                        fadeOutTime: TimeInterval = 0) {
        guard let options = options ?? AKConverter.Options(url: url) else {
            AKLog("Failed to determine output options", type: .error)
            return
        }

        let format = options.format ?? "caf"
        let directory = url.deletingLastPathComponent()
        let filename = url.deletingPathExtension().lastPathComponent
        let tempFile = directory.appendingPathComponent(filename + "_temp").appendingPathExtension("caf")
        let outputURL = directory.appendingPathComponent(filename).appendingPathExtension(format)

        // first print CAF file
        guard self.extract(to: tempFile,
                           from: startTime,
                           to: endTime,
                           fadeInTime: fadeInTime,
                           fadeOutTime: fadeOutTime) != nil else {
            AKLog("Failed to create new file", type: .error)
            return
        }

        // then convert to desired format here:
        guard FileManager.default.fileExists(atPath: tempFile.path) else {
            AKLog(tempFile, "File not found", type: .error)
            return
        }

        let converter = AKConverter(inputURL: tempFile, outputURL: outputURL, options: options)
        converter.start { error in

            if let error = error {
                AKLog("Done, error", error, type: .error)
            }

            do {
                // clean up temp file
                try FileManager.default.removeItem(at: tempFile)
            } catch {
                AKLog("Unable to remove temp file at", tempFile, type: .error)
            }
        }
    }
}
