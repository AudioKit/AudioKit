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
    public func toAVAudioPCMBuffer() -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat,
                                            frameCapacity: AVAudioFrameCount(self.length)) else { return nil }

        do {
            try self.read(into: buffer)
        } catch let error as NSError {
            AKLog("Cannot read into buffer " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }

        return buffer
    }

    public func toFloatChannelData() -> FloatChannelData? {
        guard let pcmBuffer = self.toAVAudioPCMBuffer(),
            let pcmFloatChannelData = pcmBuffer.floatChannelData else { return nil }

        let channelCount = Int(pcmBuffer.format.channelCount)
        let frameLength = Int(pcmBuffer.frameLength)
        let stride = pcmBuffer.stride

        // Preallocate our Array so we're not constantly thrashing while resizing as we append.
        var result = Array(repeating: [Float](zeros: frameLength), count: channelCount)

        // Loop across our channels...
        for channel in 0 ..< channelCount {
            // Make sure we go through all of the frames...
            for sampleIndex in 0 ..< frameLength {
                result[channel][sampleIndex] = pcmFloatChannelData[channel][sampleIndex * stride]
            }
        }

        return result
    }

    public func extractSelection(into outputURL: URL,
                                 from startTime: TimeInterval,
                                 to endTime: TimeInterval) -> AVAudioFile? {
        guard let inputBuffer = toAVAudioPCMBuffer() else {
            AKLog("Error reading into input buffer", type: .error)
            return nil
        }

        guard let editedBuffer = inputBuffer.extract(from: startTime, to: endTime) else {
            AKLog("Failed to create edited buffer", type: .error)

            return nil
        }

        guard let outputFile = try? AVAudioFile(url: outputURL, fromBuffer: editedBuffer) else {
            AKLog("Failed to write new file at", outputURL, type: .error)
            return nil
        }

        return outputFile
    }
}
