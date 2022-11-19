// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Functions specific to buffering audio
extension AudioPlayer {
    // Fills the buffer with data read from the linked audio file
    func updateBuffer() {
        guard let file = file else {
            // don't print this error if there is a buffer already set, just return
            if buffer == nil {
                Log("It's not possible to create edited buffers without a file reference.", type: .error)
            }
            return
        }

        let sampleRate: Double = file.fileFormat.sampleRate
        let processingFormat = file.processingFormat
        var startFrame = AVAudioFramePosition(editStartTime * sampleRate)
        let endTime = editEndTime > 0 ? editEndTime : duration
        var endFrame = AVAudioFramePosition(endTime * sampleRate)

        // if we are going to be reversing the buffer, we need to think ahead a bit
        // since the edit points would be reversed as well, we swap them here:
        if isReversed {
            let revStartTime = editEndTime > 0 ? duration - editEndTime : duration
            let revEndTime = duration - editStartTime

            startFrame = AVAudioFramePosition(revStartTime * sampleRate)
            endFrame = AVAudioFramePosition(revEndTime * sampleRate)
        }

        guard file.length > 0 else {
            Log("Could not set PCM buffer in " +
                "\(file.url.lastPathComponent) length = 0.", type: .error)
            return
        }

        let framesToRead: AVAudioFramePosition = endFrame - startFrame

        guard framesToRead > 0 else {
            Log("Error, endFrame must be after startFrame. Unable to fill buffer.",
                "startFrame", startFrame,
                "endFrame", endFrame,
                type: .error)
            return
        }

        // AVAudioFrameCount is unsigned so cast it after the zero check
        frameCount = AVAudioFrameCount(framesToRead)

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                               frameCapacity: frameCount) else { return }

        do {
            file.framePosition = startFrame
            // read the requested frame count from the file
            try file.read(into: pcmBuffer, frameCount: frameCount)

        } catch let err as NSError {
            Log("Couldn't read data into buffer. \(err)", type: .error)
            return
        }

        let playerChannelCount = playerNode.outputFormat(forBus: 0).channelCount

        if pcmBuffer.format.channelCount < playerChannelCount {
            Log("Copying mono data to 2 channel buffer...", pcmBuffer.format)

            guard let tmpBuffer = AVAudioPCMBuffer(pcmFormat: playerNode.outputFormat(forBus: 0),
                                                   frameCapacity: frameCount),
                let monoData = pcmBuffer.floatChannelData
            else {
                Log("Failed to setup mono conversion buffer", type: .error)
                return
            }

            // TODO: this creates a situation where the buffer is copied twice if it needs to be reversed
            // i is the index in the buffer
            for i in 0 ..< Int(pcmBuffer.frameLength) {
                // n is the channel
                for n in 0 ..< Int(playerChannelCount) {
                    //                    let sample = monoData[0][i]
                    tmpBuffer.floatChannelData?[n][i] = monoData[0][i]
                    // Log(sample)
                }
            }
            tmpBuffer.frameLength = pcmBuffer.frameLength
            buffer = tmpBuffer

        } else {
            buffer = pcmBuffer
        }

        // Now, we'll reverse the data in the buffer if specified
        if isReversed {
            Log("Reversing...")
            reverseBuffer()
        }

        // these are only stored to check if the buffer needs to be updated in subsequent fills
        startingFrame = startFrame
        endingFrame = endFrame
    }

    // Read the buffer in backwards
    fileprivate func reverseBuffer() {
        guard isBuffered, let buffer = buffer else { return }
        if let reversedBuffer = buffer.reverse() {
            self.buffer = reversedBuffer
        }
    }

    fileprivate func normalizeBuffer() {
        guard isBuffered, let buffer = buffer else { return }
        if let normalizedBuffer = buffer.normalize() {
            self.buffer = normalizedBuffer
        }
    }

    /// Apply sample level fades to the internal buffer.
    ///  - Parameters:
    ///     - inTime specified in seconds, 0 if no fade
    ///     - outTime specified in seconds, 0 if no fade
    fileprivate func fadeBuffer(inTime: TimeInterval = 0, outTime: TimeInterval = 0) {
        guard isBuffered, let buffer = buffer else { return }
        if let fadedBuffer = buffer.fade(inTime: inTime,
                                         outTime: outTime)
        {
            self.buffer = fadedBuffer
        }
    }
}
