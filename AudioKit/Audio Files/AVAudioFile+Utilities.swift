// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate

extension AVAudioFile {
    /// Duration in seconds
    public var duration: TimeInterval {
        return Double(length) / fileFormat.sampleRate
    }
}

extension AVAudioFile {
    /// Get a 2d array of Floats suitable for passing to AKWaveformLayer or other visualization classes
    public func getWaveformData(with samplesPerPixel: Int) -> FloatChannelData? {
        let totalFrames = AVAudioFrameCount(length)
        let framesPerBuffer: AVAudioFrameCount = totalFrames / AVAudioFrameCount(samplesPerPixel)

        guard let rmsBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                               frameCapacity: AVAudioFrameCount(framesPerBuffer)) else { return nil }

        let channelCount = Int(processingFormat.channelCount)
        var data = Array(repeating: [Float](zeros: samplesPerPixel), count: channelCount)
        var startFrame: AVAudioFramePosition = 0

        for i in 0 ..< samplesPerPixel {
            do {
                framePosition = startFrame
                try read(into: rmsBuffer, frameCount: framesPerBuffer)

            } catch let err as NSError {
                AKLog("Error: Couldn't read into buffer. \(err)", log: .fileHandling, type: .error)
                return nil
            }

            guard let floatData = rmsBuffer.floatChannelData else { return nil }

            for channel in 0 ..< channelCount {
                var rms: Float = 0.0
                vDSP_rmsqv(floatData[channel], 1, &rms, vDSP_Length(rmsBuffer.frameLength))
                data[channel][i] = rms
            }
            startFrame += AVAudioFramePosition(framesPerBuffer)
        }
        return data
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
