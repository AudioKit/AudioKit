//
//  AKPlayer+Buffering.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKPlayer {

    // Fills the buffer with data read from audioFile
    internal func updateBuffer(force: Bool = false) {
        if !isBuffered { return }
        guard let audioFile = audioFile else { return }

        let fileFormat = audioFile.fileFormat
        let processingFormat = audioFile.processingFormat
        var startFrame = AVAudioFramePosition(startTime * fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(endTime * fileFormat.sampleRate)

        // if we are going to be reversing the buffer, we need to think ahead a bit
        // since the edit points would be reversed as well, we swap them here:
        if isReversed {
            let revEndTime = duration - startTime
            let revStartTime = endTime > 0 ? duration - endTime : duration

            startFrame = AVAudioFramePosition(revStartTime * fileFormat.sampleRate)
            endFrame = AVAudioFramePosition(revEndTime * fileFormat.sampleRate)
        }

        var updateNeeded = force ||
            buffer == nil ||
            startFrame != startingFrame ||
            endFrame != endingFrame

        if loop.needsUpdate && isLooping {
            updateNeeded = true
        }

        if fade.needsUpdate && isFaded {
            updateNeeded = true
        }

        if !updateNeeded {
            // AKLog("No buffer update needed")
            return
        }

        guard audioFile.length > 0 else {
            AKLog("ERROR updateBuffer: Could not set PCM buffer -> " +
                "\(audioFile.fileNamePlusExtension) length = 0.")
            return
        }

        frameCount = AVAudioFrameCount(endFrame - startFrame)

        guard frameCount > 0 else {
            AKLog("totalFrames to play is \(frameCount). Bailing.")
            return
        }

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount) else { return }

        do {
            audioFile.framePosition = startFrame
            // read the requested frame count from the file
            try audioFile.read(into: pcmBuffer, frameCount: frameCount)

            buffer = pcmBuffer

        } catch let err as NSError {
            AKLog("ERROR AKPlayer: Couldn't read data into buffer. \(err)")
            return
        }

        if isLooping {
            loop.needsUpdate = false
        }

        if isNormalized {
            normalizeBuffer()
        }

        // Now, we'll reverse the data in the buffer if specified
        if isReversed {
            reverseBuffer()
        }

        if isFaded {
            fadeBuffer(inTime: fade.inTime, outTime: fade.outTime)
            fade.needsUpdate = false
        }

        // these are only stored to check if the buffer needs to be updated in subsequent fills
        startingFrame = startFrame
        endingFrame = endFrame

        // AKLog("Filled buffer from \(startTime) to \(endTime)")
    }

    // Read the buffer in backwards
    fileprivate func reverseBuffer() {
        guard isBuffered, let buffer = self.buffer else { return }
        if let reversededBuffer = buffer.reverse() {
            self.buffer = reversededBuffer
            AKLog("Reversed Buffer")
        }
    }

    fileprivate func normalizeBuffer() {
        guard isBuffered, let buffer = self.buffer else { return }
        if let normalizedBuffer = buffer.normalize() {
            self.buffer = normalizedBuffer
            AKLog("Normalized Buffer")
        }
    }

    /// Apply sample level fades to the internal buffer.
    ///  - Parameters:
    ///     - inTime specified in seconds, 0 if no fade
    ///     - outTime specified in seconds, 0 if no fade
    fileprivate func fadeBuffer(inTime: Double = 0, outTime: Double = 0) {
        guard isBuffered, let buffer = self.buffer else { return }
        if let fadedBuffer = buffer.fade(inTime: inTime,
                                         outTime: outTime,
                                         inRampType: fade.inRampType,
                                         outRampType: fade.outRampType) {
            self.buffer = fadedBuffer
            AKLog("Faded Buffer")
        }
    }

}
