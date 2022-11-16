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
        guard let engine = playerNode.engine else {
            Log("🛑 Error: AudioPlayer must be attached before playback.", type: .error)
            return
        }

        guard engine.isRunning else {
            Log("🛑 Error: AudioPlayer's engine must be running before playback.", type: .error)
            return
        }

        guard status != .playing else { return }

        guard status != .paused else {
            resume()
            return
        }

        editStartTime = startTime ?? editStartTime
        editEndTime = endTime ?? editEndTime

        if let nodeTime = playerNode.lastRenderTime, let whenTime = when {
            timeBeforePlay = whenTime.timeIntervalSince(otherTime: nodeTime)
        } else {
            timeBeforePlay = playerTime
        }

        schedule(at: when,completionCallbackType: completionCallbackType)
        playerNode.play()
        status = .playing
    }

    /// Pauses audio player. Calling play() will resume playback.
    func pause() {
        guard status == .playing else { return }
        pausedTime = currentTime
        playerNode.pause()
        status = .paused
    }

    /// Resumes playback immediately if the player is paused.
    func resume() {
        guard status == .paused else { return }
        playerNode.play()
        status = .playing
    }

    /// Stop audio player. This won't generate a callback event
    func stop() {
        guard status != .stopped else { return }
        status = .stopped
        playerNode.stop()
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

    /// The current playback time, in seconds.
    var currentTime: TimeInterval {
        var time = editStartTime
        let timeBeforePlay = timeBeforePlay ?? 0

        if status == .playing {
            if let playerTime = playerTime {
                if playerTime > timeBeforePlay {
                    time += playerTime - timeBeforePlay
                }
            }
        } else if status == .paused {
            time = pausedTime
        }

        return time
    }

    /// The time the node has been playing,  in seconds. This is `nil`
    /// when the node is paused or stopped. The node's "playerTime" is not
    /// stopped when the file completes playback.
    var playerTime: TimeInterval? {
        guard let nodeTime = playerNode.lastRenderTime,
              nodeTime.isSampleTimeValid,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime)
        else { return nil }

        let sampleTime = Double(playerTime.sampleTime)
        let sampleRate = playerTime.sampleRate

        let time = sampleTime / sampleRate

        if isLooping {
            let duration = editEndTime - editStartTime
            return time.truncatingRemainder(dividingBy: duration)
        } else {
            return time
        }
    }
}

public extension AudioPlayer {
    /// Synonym for isPlaying
    var isStarted: Bool { isPlaying }

    /// Synonym for play()
    func start() {
        play()
    }
}
