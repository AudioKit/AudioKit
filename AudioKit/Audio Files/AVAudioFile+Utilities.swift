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

// Moved from AKAudioFile properties as convenience utilities
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
}
