// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AudioPlayer {
    // MARK: - Playback

    /// Play now or at a future time
    /// - Parameters:
    ///   - when: What time to schedule for. A value of nil means now or will
    ///   use a pre-existing scheduled time.
    ///   - completionCallbackType: Constants that specify when the completion handler must be invoked.
    public func play(from startTime: TimeInterval? = nil,
                     to endTime: TimeInterval? = nil,
                     at when: AVAudioTime? = nil,
                     completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack) {
        guard !isPlaying || isPaused else { return }

        guard let engine = playerNode.engine else {
            Log("🛑 Error: AudioPlayer must be attached before playback.", type: .error)
            return
        }

        guard engine.isRunning else {
            Log("🛑 Error: AudioPlayer's engine must be running before playback.", type: .error)
            return
        }

        if when != nil {
            scheduleTime = nil
            playerNode.stop()
        }

        editStartTime = startTime ?? editStartTime
        editEndTime = endTime ?? editEndTime

        if !isScheduled {
            schedule(at: when,
                     completionCallbackType: completionCallbackType)
        }

        playerNode.play()
        isPlaying = true
        isPaused = false
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    public func pause() {
        guard isPlaying, !isPaused else { return }
        pausedTime = getCurrentTime()
        playerNode.pause()
        isPaused = true
    }

    /// Gets the accurate playhead time regardless of seeking and pausing
    /// Can't be relied on if playerNode has its playstate modified directly
    public func getCurrentTime() -> TimeInterval {
        if let nodeTime = playerNode.lastRenderTime,
           nodeTime.isSampleTimeValid && nodeTime.isHostTimeValid,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return (Double(playerTime.sampleTime) / playerTime.sampleRate) + editStartTime
        }
        return pausedTime
    }

    /// Sets the player's audio file to a certain time in the track (in seconds)
    /// and respects the players current play state
    /// - Parameters:
    ///   - time seconds into the audio file to set playhead
    public func seek(time: TimeInterval) {
        let wasPlaying = isPlaying
        
        // cancels any scheduled events
        playerNode.stop()

        editStartTime = time
        editEndTime = duration

        if wasPlaying && !isPaused {
            play(from: editStartTime, to: editEndTime)

        } else {
            pausedTime = TimeInterval(time)
        }
    }
}

extension AudioPlayer: Toggleable {
    /// Synonym for isPlaying
    public var isStarted: Bool { isPlaying }

    /// Synonym for play()
    public func start() {
        play()
    }

    /// Stop audio player. This won't generate a callback event
    public func stop() {
        guard isPlaying else { return }
        pausedTime = getCurrentTime()
        isPlaying = false
        playerNode.stop()
        scheduleTime = nil
    }
}
