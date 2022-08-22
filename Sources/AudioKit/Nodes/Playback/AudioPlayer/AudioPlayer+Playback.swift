// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public extension AudioPlayer {
    // MARK: - Playback

    /// Play now or at a future time
    /// - Parameters:
    ///   - when: What time to schedule for. A value of nil means now or will
    ///   use a pre-existing scheduled time.
    ///   - completionCallbackType: Constants that specify when the completion handler must be invoked.
    func play(from startTime: TimeInterval? = nil,
              to endTime: TimeInterval? = nil,
              at when: AVAudioTime? = nil,
              completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack)
    {
        editStartTime = startTime ?? editStartTime
        editEndTime = endTime ?? editEndTime

        guard let engine = playerNode.engine else {
            Log("🛑 Error: AudioPlayer must be attached before playback.", type: .error)
            return
        }

        guard engine.isRunning else {
            Log("🛑 Error: AudioPlayer's engine must be running before playback.", type: .error)
            return
        }

        if let renderTime = playerNode.lastRenderTime, let whenTime = when {
            timeBeforePlay = whenTime.timeIntervalSince(otherTime: renderTime) ?? 0.0
        }

        switch status {
        case .stopped:
            schedule(at: when,
                     completionCallbackType: completionCallbackType)

            playerNode.play()
            status = .playing
        case .playing:
            // player is already playing
            return
        case .paused:
            resume()
        case .scheduling:
            // player is already scheduling
            return
        }
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    func pause() {
        guard status == .playing else { return }
        pausedTime = getCurrentTime()
        playerNode.pause()
        status = .paused
    }

    /// Resumes audio player from paused time
    func resume() {
        playerNode.play()
        status = .playing
    }

    /// Gets the accurate playhead time regardless of seeking and pausing
    /// Can't be relied on if playerNode has its playstate modified directly
    func getCurrentTime() -> TimeInterval {
        switch status {
        case .playing:
            if let nodeTime = playerNode.lastRenderTime,
               nodeTime.isSampleTimeValid,
               let playerTime = playerNode.playerTime(forNodeTime: nodeTime)
            {
                let currTime = Double(playerTime.sampleTime) / playerTime.sampleRate

                // Don't count time before file starts playing
                if currTime < timeBeforePlay {
                    return editStartTime
                } else {
                    return currTime + editStartTime - timeBeforePlay
                }
            } else {
                return editStartTime
            }
        case .paused:
            return pausedTime
        default:
            return editStartTime
        }
    }

    /// Sets the player's audio file to a certain time in the track (in seconds)
    /// and respects the players current play state
    /// - Parameters:
    ///   - time seconds into the audio file to set playhead
    func seek(time: TimeInterval) {
        let time = time.clamped(to: 0 ... duration)

        if status == .playing {
            isSeeking = true
            stop()
            play(from: time, to: duration)
            isSeeking = false
        } else {
            editStartTime = time
            editEndTime = duration
        }
    }
}

public extension AudioPlayer {
    /// Synonym for isPlaying
    var isStarted: Bool { status == .playing }

    /// Synonym for play()
    func start() {
        play()
    }

    /// Stop audio player. This won't generate a callback event
    func stop() {
        guard status == .playing else { return }
        pausedTime = getCurrentTime()
        status = .stopped
        playerNode.stop()
    }
}
