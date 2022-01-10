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
        guard let engine = playerNode.engine else {
            Log("🛑 Error: AudioPlayer must be attached before playback.", type: .error)
            return
        }

        guard engine.isRunning else {
            Log("🛑 Error: AudioPlayer's engine must be running before playback.", type: .error)
            return
        }
        switch status {
        case .stopped:
            editStartTime = startTime ?? editStartTime
            editEndTime = endTime ?? editEndTime

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
        case .completed:
            // reset the status and play again if isLooping and not buffered
            if isLooping && !isBuffered {
                status = .stopped
                play()
            } else if !isLooping && !isBuffered {
                status = .stopped
            }
        }
    }

    /// Pauses audio player. Calling play() will resume from the paused time.
    public func pause() {
        guard status == .playing || status == .completed else { return }
        pausedTime = getCurrentTime()
        playerNode.pause()
        status = .paused
    }
    
    /// Resumes audio player from paused time
    public func resume() {
        playerNode.play()
        status = .playing
    }

    /// Gets the accurate playhead time regardless of seeking and pausing
    /// Can't be relied on if playerNode has its playstate modified directly
    public func getCurrentTime() -> TimeInterval {
        if let nodeTime = playerNode.lastRenderTime,
           nodeTime.isSampleTimeValid,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            return (Double(playerTime.sampleTime) / playerTime.sampleRate) + editStartTime
        } else if status == .paused {
            return pausedTime
        }
        return editStartTime
    }

    /// Sets the player's audio file to a certain time in the track (in seconds)
    /// and respects the players current play state
    /// - Parameters:
    ///   - time seconds into the audio file to set playhead
    public func seek(time: TimeInterval) {
        let time = time.clamped(to: 0...duration)

        if status == .playing {
            stop()
            play(from: time, to: duration)
        } else {
            editStartTime = time
            editEndTime = duration
        }
    }
}

extension AudioPlayer {
    /// Synonym for isPlaying
    public var isStarted: Bool { status == .playing }

    /// Synonym for play()
    public func start() {
        play()
    }

    /// Stop audio player. This won't generate a callback event
    public func stop() {
        guard status == .playing else { return }
        pausedTime = getCurrentTime()
        playerNode.stop()
        status = .stopped
    }
}
