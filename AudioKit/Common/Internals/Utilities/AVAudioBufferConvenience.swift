//
//  AVAudioBufferConvenience.swift
//  AudioKit
//
//  Created by David O'Neill on 9/7/17.
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
}
