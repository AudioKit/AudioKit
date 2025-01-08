// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CryptoKit

public extension AVAudioPCMBuffer {
    /// Hash useful for testing
    var md5: String {
        var sampleData = Data()

        if let floatChannelData = floatChannelData {
            for frame in 0 ..< frameCapacity {
                for channel in 0 ..< format.channelCount {
                    let sample = floatChannelData[Int(channel)][Int(frame)]

                    withUnsafePointer(to: sample) { ptr in
                        sampleData.append(UnsafeBufferPointer(start: ptr, count: 1))
                    }
                }
            }
        }

        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            let digest = Insecure.MD5.hash(data: sampleData)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } else {
            // Fallback on earlier versions
            return "Oh well, old version"
        }
    }

    var isSilent: Bool {
        if let floatChannelData = floatChannelData {
            for channel in 0 ..< format.channelCount {
                for frame in 0 ..< frameLength {
                    if floatChannelData[Int(channel)][Int(frame)] != 0.0 {
                        return false
                    }
                }
            }
        }
        return true
    }

    /// Add to an existing buffer
    ///
    /// - Parameter buffer: Buffer to append
    func append(_ buffer: AVAudioPCMBuffer) {
        append(buffer, startingFrame: 0, frameCount: buffer.frameLength)
    }

    /// Add to an existing buffer with specific starting frame and size
    /// - Parameters:
    ///   - buffer: Buffer to append
    ///   - startingFrame: Starting frame location
    ///   - frameCount: Number of frames to append
    func append(_ buffer: AVAudioPCMBuffer,
                startingFrame: AVAudioFramePosition,
                frameCount: AVAudioFrameCount)
    {
        precondition(format == buffer.format,
                     "Format mismatch")
        precondition(startingFrame + AVAudioFramePosition(frameCount) <= AVAudioFramePosition(buffer.frameLength),
                     "Insufficient audio in buffer")
        precondition(frameLength + frameCount <= frameCapacity,
                     "Insufficient space in buffer")

        for channel in 0..<Int(format.channelCount) {
            let dst = floatChannelData![channel]
            let src = buffer.floatChannelData![channel]

            memcpy(dst.advanced(by: stride * Int(frameLength)),
                   src.advanced(by: stride * Int(startingFrame)),
                   Int(frameCount) * stride * MemoryLayout<Float>.size)
        }

        frameLength += frameCount
    }

    /// Copies data from another PCM buffer.  Will copy to the end of the buffer (frameLength), and
    /// increment frameLength. Will not exceed frameCapacity.
    ///
    /// - Parameter buffer: The source buffer that data will be copied from.
    /// - Parameter readOffset: The offset into the source buffer to read from.
    /// - Parameter frames: The number of frames to copy from the source buffer.
    /// - Returns: The number of frames copied.
    @discardableResult func copy(from buffer: AVAudioPCMBuffer,
                                 readOffset: AVAudioFrameCount = 0,
                                 frames: AVAudioFrameCount = 0) -> AVAudioFrameCount
    {
        let remainingCapacity = frameCapacity - frameLength
        if remainingCapacity == 0 {
            Log("AVAudioBuffer copy(from) - no capacity!")
            return 0
        }

        if format != buffer.format {
            Log("AVAudioBuffer copy(from) - formats must match!")
            return 0
        }

        let totalFrames = Int(min(min(frames == 0 ? buffer.frameLength : frames, remainingCapacity),
                                  buffer.frameLength - readOffset))

        if totalFrames <= 0 {
            Log("AVAudioBuffer copy(from) - No frames to copy!")
            return 0
        }

        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)
        if let src = buffer.floatChannelData,
           let dst = floatChannelData
        {
            for channel in 0 ..< Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), totalFrames * frameSize)
            }
        } else if let src = buffer.int16ChannelData,
                  let dst = int16ChannelData
        {
            for channel in 0 ..< Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), totalFrames * frameSize)
            }
        } else if let src = buffer.int32ChannelData,
                  let dst = int32ChannelData
        {
            for channel in 0 ..< Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), totalFrames * frameSize)
            }
        } else {
            return 0
        }
        frameLength += AVAudioFrameCount(totalFrames)
        return AVAudioFrameCount(totalFrames)
    }

    /// Copy from a certain point tp the end of the buffer
    /// - Parameter startSample: Point to start copy from
    /// - Returns: an AVAudioPCMBuffer copied from a sample offset to the end of the buffer.
    func copyFrom(startSample: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard startSample < frameLength,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength - startSample)
        else {
            return nil
        }
        let framesCopied = buffer.copy(from: self, readOffset: startSample)
        return framesCopied > 0 ? buffer : nil
    }

    /// Copy from the beginner of a buffer to a certain number of frames
    /// - Parameter count: Length of frames to copy
    /// - Returns: an AVAudioPCMBuffer copied from the start of the buffer to the specified endSample.
    func copyTo(count: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: count) else {
            return nil
        }
        let framesCopied = buffer.copy(from: self, readOffset: 0, frames: min(count, frameLength))
        return framesCopied > 0 ? buffer : nil
    }

    /// Extract a portion of the buffer
    ///
    /// - Parameter startTime: The time of the in point of the extraction
    /// - Parameter endTime: The time of the out point
    /// - Returns: A new edited AVAudioPCMBuffer
    func extract(from startTime: TimeInterval,
                 to endTime: TimeInterval) -> AVAudioPCMBuffer?
    {
        let sampleRate = format.sampleRate
        let startSample = AVAudioFrameCount(startTime * sampleRate)
        var endSample = AVAudioFrameCount(endTime * sampleRate)

        if endSample == 0 {
            endSample = frameLength
        }

        let frameCapacity = endSample - startSample

        guard frameCapacity > 0 else {
            Log("startSample must be before endSample", type: .error)
            return nil
        }

        guard let editedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            Log("Failed to create edited buffer", type: .error)
            return nil
        }

        guard editedBuffer.copy(from: self, readOffset: startSample, frames: frameCapacity) > 0 else {
            Log("Failed to write to edited buffer", type: .error)
            return nil
        }

        return editedBuffer
    }
}

public extension AVAudioPCMBuffer {
    /// Reduce a buffer into a specified number of buckets
    /// Returns `[Float]` buckets and absolute maximum bucket value
    func reduce(bucketCount: Int) -> ([Float], Float) {
        let frameCount = Int(self.frameLength)
        guard frameCount > 0 else { return ([], 0) }
        let mono = mixToMono()
        let samples = Array(UnsafeBufferPointer(start: mono.floatChannelData![0], count: frameCount))
        let samplesPerBucket = max(1, Double(frameCount) / Double(bucketCount))

        var buckets = [Float](repeating: 0, count: bucketCount)
        var maxBucket: Float = 0
        for i in 0..<bucketCount {
            let bucketStart = Int(Double(i) * samplesPerBucket)
            let bucketEnd = min(bucketStart + Int(samplesPerBucket), frameCount)
            guard bucketStart < bucketEnd else { break }
            let bucketSamples = samples[bucketStart..<bucketEnd]
            let avgSample = bucketSamples.reduce(into: Float(0)) { currentMax, value in
                if abs(value) > abs(currentMax) {
                    currentMax = value
                }
            }
            buckets[i] = avgSample
            if abs(avgSample) > maxBucket {
                maxBucket = abs(avgSample)
            }
        }
        return (buckets, maxBucket)
    }
}

public extension AVAudioPCMBuffer {
    func visualDescription(width: Int = 60, height: Int = 15) -> String {
        assert((height - 1).isMultiple(of: 2))
        let rows = [
            format.stringDescription,
            "Frame count \(frameLength)",
            "Frame capacity \(frameCapacity)"
        ]
        let frameCount = Int(self.frameLength)
        guard self.floatChannelData != nil, frameCount > 0 else {
            return rows.joined(separator: "\n")
        }
        let (buckets, maxBucket) = reduce(bucketCount: width)
        let scaleFactor = maxBucket > 0 ? Float((height - 1) / 2) / maxBucket : 1.0
        let half = Int((Double(height) / 2).rounded(.up))
        let waveformRows = (0..<height).map { rowIndex in
            let row = height - rowIndex
            return "\(abs(row - half))│ " + String(
                buckets.map { value in
                    let scaled = value * scaleFactor
                    let max = Int(half) + Int(scaled)
                    if row > Int(half) {
                        return (max == row && scaled > 0) ? "*" : " "
                    } else if row < Int(half) {
                        return (row == max && scaled < 0) ? "*" : " "
                    } else {
                        return (row == max) ? "*" : " "
                    }
                }
            )
        }
        return (rows + [""] + waveformRows + [""]).joined(separator: "\n")
    }

    // Allows to use Quick Look in the debugger on AVAudioPCMBuffer
    // https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/CustomClassDisplay_in_QuickLook/CH01-quick_look_for_custom_objects/CH01-quick_look_for_custom_objects.html
    @objc func debugQuickLookObject() -> Any? {
        visualDescription()
    }
}

private extension AVAudioFormat {
    var stringDescription: String {
        "Format \(channelCount) ch, \(sampleRate) Hz, \(isInterleaved ? "interleaved" : "deinterleaved"), \(commonFormat.stringDescription)"
    }
}

private extension AVAudioCommonFormat {
    var stringDescription: String {
        switch self {
        case .otherFormat: "Other format"
        case .pcmFormatFloat32: "Float32"
        case .pcmFormatFloat64: "Float64"
        case .pcmFormatInt16: "Int16"
        case .pcmFormatInt32: "Int32"
        @unknown default: "Unknown"
        }
    }
}
