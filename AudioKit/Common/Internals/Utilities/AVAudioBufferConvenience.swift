//
//  AVAudioBufferConvenience.swift
//  AudioKit
//
//  Created by David O'Neill on 9/7/17.
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
        if (remainingCapacity == 0) { return 0 }
        let count = Int(
            min(
                min(frames == 0 ? buffer.frameLength : frames, remainingCapacity),
                buffer.frameLength - readOffset
            )
        )
        let frameSize = Int(format.streamDescription.pointee.mBytesPerFrame)
        if let src = floatChannelData,
            let dst = buffer.floatChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = int16ChannelData,
            let dst = buffer.int16ChannelData {
            for channel in 0..<Int(format.channelCount) {
                memcpy(dst[channel] + Int(frameLength), src[channel] + Int(readOffset), count * frameSize)
            }
        } else if let src = int32ChannelData,
            let dst = buffer.int32ChannelData {
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
    open func copyTo(endSample: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard endSample < frameLength,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: endSample) else {
            return nil
        }
        let framesCopied = buffer.copy(from: self, readOffset: 0, frames: endSample)
        return framesCopied > 0 ? buffer : nil
    }
}
