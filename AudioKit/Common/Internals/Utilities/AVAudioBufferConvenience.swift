//
//  AVAudioBufferConvenience.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

extension AVAudioPCMBuffer {

    public struct Peak {
        public init() {}
        public static var min: Float = -10_000.0
        public var time: Double = 0
        public var framePosition: Int = 0
        public var amplitude: Float = 1
    }

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
            AKLog("AVAudioBuffer copy(from) - no capacity!")
            return 0
        }

        if format != buffer.format {
            AKLog("AVAudioBuffer copy(from) - formats must match!")
            return 0
        }

        let count = Int(min(min(frames == 0 ? buffer.frameLength : frames, remainingCapacity),
                            buffer.frameLength - readOffset))

        if count <= 0 {
            AKLog("AVAudioBuffer copy(from) - No frames to copy!")
            return 0
        }

        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)
        if let src = buffer.floatChannelData,
            let dst = floatChannelData {
            for channel in 0 ..< Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = buffer.int16ChannelData,
            let dst = int16ChannelData {
            for channel in 0 ..< Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = buffer.int32ChannelData,
            let dst = int32ChannelData {
            for channel in 0 ..< Int(format.channelCount) {
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
        if let time = peak()?.time {
            return time
        }
        return 0
    }

    /// - Returns: A Peak struct containing the time, frame position and peak amplitude
    open func peak() -> Peak? {
        guard self.frameLength > 0 else { return nil }
        guard let floatData = self.floatChannelData else { return nil }

        var value = Peak()
        var position = 0
        var peakValue: Float = Peak.min
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
                let blockPeak = getPeak(from: block)

                if blockPeak > peakValue {
                    value.framePosition = position
                    value.time = Double(position / self.format.sampleRate)
                    peakValue = blockPeak
                }
                position += block.count
            }
        }

        value.amplitude = peakValue
        // AKLog(value)
        return value
    }

    // Returns the highest level in the given array
    private func getPeak(from buffer: [Float]) -> Float {
        // create variable with very small value to hold the peak value
        var peak: Float = Peak.min

        for i in 0 ..< buffer.count {
            // store the absolute value of the sample
            let absSample = abs(buffer[i])
            peak = max(peak, absSample)
        }
        return peak
    }

    /// Returns a normalized buffer
    open func normalize() -> AVAudioPCMBuffer? {
        guard let floatData = self.floatChannelData else { return self }

        let normalizedBuffer = AVAudioPCMBuffer(pcmFormat: self.format,
                                                frameCapacity: self.frameCapacity)

        let length: AVAudioFrameCount = self.frameLength
        let channelCount = Int(self.format.channelCount)

        guard let peak: AVAudioPCMBuffer.Peak = peak() else {
            AKLog("Failed getting peak amplitude, returning original buffer")
            return self
        }

        let gainFactor: Float = 1 / peak.amplitude

        // i is the index in the buffer
        for i in 0 ..< Int(length) {
            // n is the channel
            for n in 0 ..< channelCount {
                let sample = floatData[n][i] * gainFactor
                normalizedBuffer?.floatChannelData?[n][i] = sample
            }
        }
        normalizedBuffer?.frameLength = length

        // AKLog("Old Peak", peakAmplitude, "New Peak", normalizedBuffer?.peak())
        return normalizedBuffer
    }

    /// Returns a reversed buffer
    open func reverse() -> AVAudioPCMBuffer? {
        let reversedBuffer = AVAudioPCMBuffer(pcmFormat: self.format,
                                              frameCapacity: self.frameCapacity)

        var j: Int = 0
        let length: AVAudioFrameCount = self.frameLength
        let channelCount = Int(self.format.channelCount)

        // i represents the normal buffer read in reverse
        for i in (0 ..< Int(length)).reversed() {
            // n is the channel
            for n in 0 ..< channelCount {
                // we write the reverseBuffer via the j index
                reversedBuffer?.floatChannelData?[n][j] = self.floatChannelData?[n][i] ?? 0.0
            }
            j += 1
        }
        reversedBuffer?.frameLength = length
        return reversedBuffer
    }

    /// Creates a new buffer from this one that has fades applied to it. Pass 0 for either parameter
    /// if you only want one of them
    open func fade(inTime: Double,
                   outTime: Double,
                   inRampType: AKSettings.RampType = .exponential,
                   outRampType: AKSettings.RampType = .exponential) -> AVAudioPCMBuffer? {

        guard let floatData = self.floatChannelData, inTime > 0 || outTime > 0 else {
            AKLog("Error fading buffer, returning original...")
            return self
        }

        let fadeBuffer = AVAudioPCMBuffer(pcmFormat: self.format,
                                          frameCapacity: self.frameCapacity)

        let length: UInt32 = self.frameLength
        let sampleRate = self.format.sampleRate
        let channelCount = Int(self.format.channelCount)

        // AKLog("fadeBuffer() inTime: \(inTime) outTime: \(outTime)")

        // initial starting point for the gain, if there is a fade in, start it at .01 otherwise at 1
        var gain: Double = inTime > 0 ? 0.01 : 1

        let sampleTime: Double = 1.0 / sampleRate

        var fadeInPower: Double = 1
        var fadeOutPower: Double = 1

        if inRampType == .linear {
            gain = inTime > 0 ? 0 : 1
            fadeInPower = sampleTime / inTime

        } else if inRampType == .exponential {
            fadeInPower = exp(log(10) * sampleTime / inTime)
        }

        if outRampType == .linear {
            fadeOutPower = sampleTime / outTime

        } else if outRampType == .exponential {
            fadeOutPower = exp(-log(25) * sampleTime / outTime)
        }

        // TODO: .logarithmic

        // where in the buffer to end the fade in
        let fadeInSamples = Int(sampleRate * inTime)
        // where in the buffer to start the fade out
        let fadeOutSamples = Int(Double(length) - (sampleRate * outTime))

        // AKLog("rampType", rampType.rawValue, "fadeInPower", fadeInPower, "fadeOutPower", fadeOutPower)

        // i is the index in the buffer
        for i in 0 ..< Int(length) {
            // n is the channel
            for n in 0 ..< channelCount {
                if i < fadeInSamples && inTime > 0 {

                    if inRampType == .exponential {
                        gain *= fadeInPower
                    } else if inRampType == .linear {
                        gain += fadeInPower
                    }

                } else if i > fadeOutSamples && outTime > 0 {
                    if outRampType == .exponential {
                        gain *= fadeOutPower
                    } else if outRampType == .linear {
                        gain -= fadeOutPower
                    }
                } else {
                    gain = 1.0
                }

                // sanity check
                if gain > 1 {
                    gain = 1
                } else if gain < 0 {
                    gain = 0
                }

                let sample = floatData[n][i] * Float(gain)
                fadeBuffer?.floatChannelData?[n][i] = sample
            }
        }
        // update this
        fadeBuffer?.frameLength = length

        // set the buffer now to be the faded one
        return fadeBuffer
    }

}
