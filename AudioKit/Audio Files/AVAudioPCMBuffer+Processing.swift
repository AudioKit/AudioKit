// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AVAudioPCMBuffer {
    /// Read the contents of the url into this buffer
    public convenience init?(url: URL) throws {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }

        file.framePosition = 0

        self.init(pcmFormat: file.processingFormat,
                  frameCapacity: AVAudioFrameCount(file.length))

        try file.read(into: self)
    }
}

extension AVAudioPCMBuffer {
    public struct Peak {
        public init() {}
        public static let min: Float = -10_000.0
        public var time: Double = 0
        public var framePosition: Int = 0
        public var amplitude: Float = 1
    }

    /// - Returns: A Peak struct containing the time, frame position and peak amplitude
    open func peak() -> Peak? {
        guard frameLength > 0 else { return nil }
        guard let floatData = floatChannelData else { return nil }

        var value = Peak()
        var position = 0
        var peakValue: Float = Peak.min
        let chunkLength = 512
        let channelCount = Int(format.channelCount)

        while true {
            if position + chunkLength >= frameLength {
                break
            }
            for channel in 0 ..< channelCount {
                var block = Array(repeating: Float(0), count: chunkLength)

                // fill the block with frameLength samples
                for i in 0 ..< block.count {
                    if i + position >= frameLength {
                        break
                    }
                    block[i] = floatData[channel][i + position]
                }
                // scan the block
                let blockPeak = getPeak(from: block)

                if blockPeak > peakValue {
                    value.framePosition = position
                    value.time = Double(position / format.sampleRate)
                    peakValue = blockPeak
                }
                position += block.count
            }
        }

        value.amplitude = peakValue
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
        guard let floatData = floatChannelData else { return self }

        let normalizedBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                                frameCapacity: frameCapacity)

        let length: AVAudioFrameCount = frameLength
        let channelCount = Int(format.channelCount)

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

        return normalizedBuffer
    }

    /// Returns a reversed buffer
    open func reverse() -> AVAudioPCMBuffer? {
        let reversedBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                              frameCapacity: frameCapacity)

        var j: Int = 0
        let length: AVAudioFrameCount = frameLength
        let channelCount = Int(format.channelCount)

        // i represents the normal buffer read in reverse
        for i in (0 ..< Int(length)).reversed() {
            // n is the channel
            for n in 0 ..< channelCount {
                // we write the reverseBuffer via the j index
                reversedBuffer?.floatChannelData?[n][j] = floatChannelData?[n][i] ?? 0.0
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
        guard let floatData = floatChannelData, inTime > 0 || outTime > 0 else {
            AKLog("Error fading buffer, returning original...")
            return self
        }

        let fadeBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                          frameCapacity: frameCapacity)

        let length: UInt32 = frameLength
        let sampleRate = format.sampleRate
        let channelCount = Int(format.channelCount)

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

        // where in the buffer to end the fade in
        let fadeInSamples = Int(sampleRate * inTime)
        // where in the buffer to start the fade out
        let fadeOutSamples = Int(Double(length) - (sampleRate * outTime))

        // i is the index in the buffer
        for i in 0 ..< Int(length) {
            // n is the channel
            for n in 0 ..< channelCount {
                if i < fadeInSamples, inTime > 0 {
                    if inRampType == .exponential {
                        gain *= fadeInPower
                    } else if inRampType == .linear {
                        gain += fadeInPower
                    }

                } else if i > fadeOutSamples, outTime > 0 {
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
