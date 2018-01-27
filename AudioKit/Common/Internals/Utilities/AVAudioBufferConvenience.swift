//
//  AVAudioBufferConvenience.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

extension AVAudioPCMBuffer {

    /**
     Copies data from another PCM buffer.  Will copy to the end of the buffer (frameLength), and
     increment frameLength. Will not exceed frameCapacity.

     - Parameter buffer: The source buffer that data will be copied from.
     - Parameter readOffset: The offset into the source buffer to read from.
     - Parameter frames: The number of frames to copy from the source buffer.
     - Returns: The number of frames copied.
     */
    @discardableResult open func copy(from buffer: AVAudioPCMBuffer,
                                      readOffset: AVAudioFrameCount = 0,
                                      frames: AVAudioFrameCount = 0) -> AVAudioFrameCount {

        let remainingCapacity = frameCapacity - frameLength
        if remainingCapacity == 0 {
            print("AVAudioBuffer copy(from) - no capacity!")
            return 0
        }

        if format != buffer.format {
            print("AVAudioBuffer copy(from) - formats must match!")
            return 0
        }

        let count = Int(
            min(
                min(frames == 0 ? buffer.frameLength : frames, remainingCapacity),
                buffer.frameLength - readOffset
            )
        )

        if count <= 0 {
            print("AVAudioBuffer copy(from) - No frames to copy!")
            return 0
        }

        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)
        if let src = buffer.floatChannelData,
            let dst = floatChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = buffer.int16ChannelData,
            let dst = int16ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = buffer.int32ChannelData,
            let dst = int32ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else {
            return 0
        }
        frameLength += AVAudioFrameCount(count)
        return AVAudioFrameCount(count)
    }

    /// Returns an AVAudioPCMBuffer copied from a sample offset to the end of the buffer.
    open func copyFrom(startSample: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard startSample < frameLength,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength - startSample) else {
            return nil
        }
        let framesCopied = buffer.copy(from: self, readOffset: startSample)
        return framesCopied > 0 ? buffer : nil
    }

    /// Returns an AVAudioPCMBuffer copied from the start of the buffer to the specified endSample.
    open func copyTo(count: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count) else {
            return nil
        }
        let framesCopied = buffer.copy(from: self, readOffset: 0, frames: min(count, frameLength))
        return framesCopied > 0 ? buffer : nil
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
