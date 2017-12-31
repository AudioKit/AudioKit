//
//  AVAudioBufferConvenience.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

extension AVAudioPCMBuffer {

    /// Returns an AVAudioPCMBuffer copied from a sample offset to the end of the buffer.
    open func copyFrom(startSample: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard startSample < frameLength,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength - startSample)
        else {
            return nil
        }

        let count = Int(frameLength - startSample)
        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)
        if let src = floatChannelData,
            let dst = buffer.floatChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel], src[channel] + Int(startSample), count * frameSize)
            }
        } else if let src = int16ChannelData,
            let dst = buffer.int16ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel], src[channel] + Int(startSample), count * frameSize)
            }
        } else if let src = int32ChannelData,
            let dst = buffer.int32ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel], src[channel] + Int(startSample), count * frameSize)
            }
        } else {
            return nil
        }
        buffer.frameLength = AVAudioFrameCount(count)
        return buffer
    }

    /// Returns an AVAudioPCMBuffer copied from the start of the buffer to the specified endSample.
    open func copyTo(endSample: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard endSample < frameLength,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: endSample)
        else {
            return nil
        }
        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)

        if let src = buffer.floatChannelData,
            let dst = buffer.floatChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                memcpy(dst[channel], src[channel], Int(endSample) * frameSize)
            }
        } else if let src = buffer.int16ChannelData,
            let dst = buffer.int16ChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                memcpy(dst[channel], src[channel], Int(endSample) * frameSize)
            }
        } else if let src = buffer.int32ChannelData,
            let dst = buffer.int32ChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                memcpy(dst[channel], src[channel], Int(endSample) * frameSize)
            }
        } else {
            return nil
        }
        return buffer
    }

    /// - Returns: The time in seconds of the peak of the buffer or 0 if it failed
    open func peakTime() -> Double {
        guard self.frameLength > 0 else { return 0 }
        guard let floatData = self.floatChannelData else { return 0 }

        var framePosition = 0
        var position = 0
        var lastPeak: Float = -10_000.0
        let frameLength = 512
        let channelCount = Int(self.format.channelCount)

        while true {
            if position + frameLength >= self.frameLength {
                break
            }
            for channel in 0 ..< channelCount {
                var block = Array(repeating: Float(0), count: frameLength)

                // fill the block with frameLength samples
                for i in 0 ..< block.count {
                    if i + position >= self.frameLength {
                        break
                    }
                    block[i] = floatData[channel][i + position]
                }
                // scan the block
                let peak = getPeak(from: block)

                if peak > lastPeak {
                    framePosition = position
                    lastPeak = peak
                }
                position += block.count
            }
        }

        let time = Double(framePosition / self.format.sampleRate)
        return time
    }

    // return the highest level in the given array
    private func getPeak(from buffer: [Float]) -> Float {
        // create variable with very small value to hold the peak value
        var peak: Float = -10_000.0

        for i in 0 ..< buffer.count {
            // store the absolute value of the sample
            let absSample = abs(buffer[i])
            peak = max(peak, absSample)
        }
        return peak
    }
}
