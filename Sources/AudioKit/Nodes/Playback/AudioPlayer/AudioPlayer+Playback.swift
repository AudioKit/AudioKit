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

        if let startTime {
            seekStartTime = startTime
        }
        editEndTime = endTime ?? editEndTime

        if let nodeTime = playerNode.lastRenderTime, let whenTime = when {
            timeBeforePlay = whenTime.timeIntervalSince(otherTime: nodeTime) ?? 0
        } else if let playerTime = playerTime {
            timeBeforePlay = playerTime
        } else {
            timeBeforePlay = 0
        }

        if status == .paused, seekStartTime == nil {
            resume()
        } else {
            schedule(at: when, completionCallbackType: completionCallbackType)
            playerNode.play()
            status = .playing
        }
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
        timeBeforePlay = 0
        seekStartTime = nil
    }

    /// Seeks through the player's audio file by the given time (in seconds).
    /// Positive time seeks forwards, negative time seeks backwards.
    /// - Parameters:
    ///   - time seconds, relative to current playback, to seek by
    func seek(time seekTime: TimeInterval) {
        guard seekTime != 0 else { return }

        guard file != nil else { return }
        let wasPlaying = status == .playing
        let wasPaused = status == .paused
        let startTime = currentTime + seekTime
        let endTime = editEndTime

        guard startTime > 0 && startTime < endTime else {
            stop()
            if isLooping && wasPlaying { play() }
            return
        }

        playerNode.stop()
        seekStartTime = startTime

        if wasPlaying {
            isSeeking = true
            schedule(at: nil, completionCallbackType: .dataPlayedBack)
            playerNode.play()
            status = .playing
        } else if wasPaused {
            pausedTime = startTime
            status = .paused
        } else {
            status = .stopped
        }

        isSeeking = false
        timeBeforePlay = 0
    }

    /// The current playback position, in range [0, 1].
    /// The start and end positions are 0 and 1, respectively.
    var currentPosition: Double {
        let duration = editEndTime - editStartTime
        return (currentTime / duration).clamped(to: 0...1)
    }

    /// The current playback time, in seconds.
    var currentTime: TimeInterval {
        guard status != .paused else { return pausedTime }
        guard status != .stopped else { return playbackStartTime }

        let startTime = playbackStartTime
        let duration = editEndTime - startTime

        guard let playerTime = isBuffered && isLooping
                ? playerTime?.truncatingRemainder(dividingBy: duration)
                : playerTime
        else { return startTime }

        let timeBeforePlay = playerTime >= timeBeforePlay ? timeBeforePlay : 0
        let time = startTime + playerTime - timeBeforePlay

        return time.clamped(to: startTime...startTime + duration)
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

        return sampleTime / sampleRate
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
