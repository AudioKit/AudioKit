// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer {
    /// Schedule a file or buffer. You can call this to schedule playback in the future
    /// or the player will call it when play() is called to load the audio data
    /// - Parameters:
    ///   - when: What time to schedule for
    ///   - completionCallbackType: Constants that specify when the completion handler must be invoked.
    public func schedule(at when: AVAudioTime? = nil,
                         completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        scheduleTime = when ?? AVAudioTime.now()

        if isBuffered {
            updateBuffer()
            scheduleBuffer(at: when,
                           completionCallbackType: completionCallbackType)

        } else if file != nil {
            scheduleSegment(at: when,
                            completionCallbackType: completionCallbackType)

        } else {
            Log("The player needs a file or a valid buffer to schedule", type: .error)
            scheduleTime = nil
        }
    }

    // play from disk rather than ram
    private func scheduleSegment(at audioTime: AVAudioTime?,
                                 completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        guard let file = file else {
            Log("File is nil")
            return
        }

        let startFrame = AVAudioFramePosition(editStartTime * file.fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(editEndTime * file.fileFormat.sampleRate)

        if endFrame == 0 {
            endFrame = file.length
        }

        let totalFrames = (file.length - startFrame) - (file.length - endFrame)

        guard totalFrames > 0 else {
            Log("Unable to schedule file. totalFrames to play: \(totalFrames). file.length: \(file.length)", type: .error)
            return
        }

        let frameCount = AVAudioFrameCount(totalFrames)

        playerNode.scheduleSegment(file,
                                   startingFrame: startFrame,
                                   frameCount: frameCount,
                                   at: audioTime,
                                   completionCallbackType: completionCallbackType) { callbackType in
            self.internalCompletionHandler()
        }

        playerNode.prepare(withFrameCount: frameCount)
    }

    private func scheduleBuffer(at audioTime: AVAudioTime?,
                                completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        if playerNode.outputFormat(forBus: 0) != buffer?.format {
            Log("Format of the buffer doesn't match the player")
            Log("Player", playerNode.outputFormat(forBus: 0), "Buffer", buffer?.format)
            updateBuffer(force: true)
        }

        guard let buffer = buffer else {
            Log("Failed to fill buffer")
            return
        }

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts]

        if isLooping {
            bufferOptions = [.loops, .interrupts]
        }

        playerNode.scheduleBuffer(buffer,
                                  at: audioTime,
                                  options: bufferOptions,
                                  completionCallbackType: completionCallbackType) { callbackType in
            self.internalCompletionHandler()
        }

        playerNode.prepare(withFrameCount: buffer.frameLength)
    }
}
