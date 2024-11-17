// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

public extension AVAudioPCMBuffer {
    /// Read the contents of the url into this buffer
    convenience init?(url: URL) throws {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        try self.init(file: file)
    }

    /// Read entire file and return a new AVAudioPCMBuffer with its contents
    convenience init?(file: AVAudioFile) throws {
        file.framePosition = 0

        self.init(pcmFormat: file.processingFormat,
                  frameCapacity: AVAudioFrameCount(file.length))

        try file.read(into: self)
    }
}

public extension AVAudioPCMBuffer {
    /// Returns audio data as an `Array` of `Float` Arrays.
    ///
    /// If stereo:
    /// - `floatChannelData?[0]` will contain an Array of left channel samples as `Float`
    /// - `floatChannelData?[1]` will contains an Array of right channel samples as `Float`
    func toFloatChannelData() -> FloatChannelData? {
        // Do we have PCM channel data?
        guard let pcmFloatChannelData = floatChannelData else {
            return nil
        }

        let channelCount = Int(format.channelCount)
        let frameLength = Int(self.frameLength)
        let stride = self.stride

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

public extension AVAudioPCMBuffer {
    /// Local maximum containing the time, frame position and  amplitude
    struct Peak {
        /// Initialize the peak, to be able to use outside of AudioKit
        public init() {}
        internal static let min: Float = -10000.0
        /// Time of the peak
        public var time: Double = 0
        /// Frame position of the peak
        public var framePosition: Int = 0
        /// Peak amplitude
        public var amplitude: Float = 1
    }

    /// Find peak in the buffer
    /// - Returns: A Peak struct containing the time, frame position and peak amplitude
    func peak() -> Peak? {
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
                let blockPeak = getPeakAmplitude(from: block)

                if blockPeak > peakValue {
                    value.framePosition = position
                    value.time = Double(position) / Double(format.sampleRate)
                    peakValue = blockPeak
                }
                position += block.count
            }
        }

        value.amplitude = peakValue
        return value
    }

    // Returns the highest level in the given array
    private func getPeakAmplitude(from buffer: [Float]) -> Float {
        // create variable with very small value to hold the peak value
        var peak: Float = Peak.min

        for i in 0 ..< buffer.count {
            // store the absolute value of the sample
            let absSample = abs(buffer[i])
            peak = max(peak, absSample)
        }
        return peak
    }

    /// - Returns: A normalized buffer
    func normalize() -> AVAudioPCMBuffer? {
        guard let floatData = floatChannelData else { return self }

        let normalizedBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                                frameCapacity: frameCapacity)

        let length: AVAudioFrameCount = frameLength
        let channelCount = Int(format.channelCount)

        guard let peak: AVAudioPCMBuffer.Peak = peak() else {
            Log("Failed getting peak amplitude, returning original buffer")
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

    /// - Returns: A reversed buffer
    func reverse() -> AVAudioPCMBuffer? {
        let reversedBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                              frameCapacity: frameCapacity)

        var j = 0
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

    /// - Returns: A new buffer from this one that has fades applied to it. Pass 0 for either parameter
    /// if you only want one of them. The ramp is exponential by default.
    func fade(inTime: Double, outTime: Double, linearRamp: Bool = false) -> AVAudioPCMBuffer? {
        guard let floatData = self.floatChannelData, inTime > 0 || outTime > 0 else {
            Log("Error fading buffer, returning original...")
            return self
        }

        let sampleRate = self.format.sampleRate
        let totalDuration = Double(self.frameLength) / sampleRate

        let sampleTime = 1.0 / sampleRate
        let fadeInPower = linearRamp ? sampleTime / inTime : exp(log(10) * sampleTime / inTime)
        let fadeOutPower = linearRamp ? sampleTime / outTime : exp(-log(25) * sampleTime / outTime)

        let fadeInBuffer: AVAudioPCMBuffer? = inTime > 0 ? self.extract(from: 0, to: inTime) : nil
        let fadeOutBuffer: AVAudioPCMBuffer? = outTime > 0 ? self.extract(from: totalDuration - outTime, to: totalDuration) : nil

        var gain: Double = 1

        // Only FadeIn if inTime was provided
        if let fadeInBuffer = fadeInBuffer {
            gain = 0.01

            for i in 0 ..< Int(fadeInBuffer.frameLength) {
                gain = linearRamp ? gain + fadeInPower : gain * fadeInPower
                gain = min(max(gain, 0), 1)  // clamp gain between 0 and 1
                for n in 0 ..< Int(fadeInBuffer.format.channelCount) {
                    fadeInBuffer.floatChannelData?[n][i] *= Float(gain)
                }
            }
        }

        // Only FadeOut if outTime was provided
        if let fadeOutBuffer = fadeOutBuffer {
            gain = 1

            for i in 0 ..< Int(fadeOutBuffer.frameLength) {
                gain = linearRamp ? gain - fadeOutPower : gain * fadeOutPower
                gain = min(max(gain, 0), 1)  // clamp gain between 0 and 1
                for n in 0 ..< Int(fadeOutBuffer.format.channelCount) {
                    fadeOutBuffer.floatChannelData?[n][i] *= Float(gain)
                }
            }
        }

        // Create the result buffer by appending fadeIn, middle part of original buffer, and fadeOut
        let resultBuffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: self.frameCapacity)!

        if let fadeInBuffer = fadeInBuffer {
            resultBuffer.append(fadeInBuffer)
        }

        if inTime < totalDuration - outTime {
            resultBuffer.append(self.extract(from: inTime, to: totalDuration - outTime)!)
        }

        if let fadeOutBuffer = fadeOutBuffer {
            resultBuffer.append(fadeOutBuffer)
        }

        return resultBuffer
    }
}

extension AVAudioPCMBuffer {
    var rms: Float {
        guard let data = floatChannelData else { return 0 }

        let channelCount = Int(format.channelCount)
        var rms: Float = 0.0
        for i in 0 ..< channelCount {
            var channelRms: Float = 0.0
            vDSP_rmsqv(data[i], 1, &channelRms, vDSP_Length(frameLength))
            rms += abs(channelRms)
        }
        let value = (rms / Float(channelCount))
        return value
    }
}

public extension AVAudioPCMBuffer {
    func mixToMono() -> AVAudioPCMBuffer {
        let newFormat = AVAudioFormat(standardFormatWithSampleRate: format.sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: newFormat, frameCapacity: frameLength)!
        buffer.frameLength = frameLength

        let stride = vDSP_Stride(1)
        let result = buffer.floatChannelData![0]
        for channel in 0 ..< format.channelCount {
            let channelData = self.floatChannelData![Int(channel)]
            vDSP_vadd(channelData, stride, result, stride, result, stride, vDSP_Length(frameLength))
        }
        return buffer
    }
}
