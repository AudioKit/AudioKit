// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

// MARK: - Loading

extension AKPlayer {
    /// Replace the contents of the player with this url. Note that if your processingFormat changes
    /// you should dispose this AKPlayer and create a new one instead.
    @objc public func load(url: URL) throws {
        let file = try AVAudioFile(forReading: url)
        try load(audioFile: file)
    }

    /// Load a new audio file into this player. Note that if your processingFormat changes
    /// you should dispose this AKPlayer and create a new one instead.
    @objc public func load(audioFile: AVAudioFile) throws {
        if audioFile.processingFormat != processingFormat {
            AKLog("⚠️ Warning: This file is a different format than the previously loaded one. " +
                "You should make a new AKPlayer instance and reconnect. " +
                "load() is only available for files that are the same format.")
            throw NSError(domain: "Processing format doesn't match", code: 0, userInfo: nil)
        }

        self.audioFile = audioFile
        initialize(restartIfPlaying: false)
        // will reset the stored start / end times or update the buffer
        preroll()
    }

    /// Mostly applicable to buffered players, this loads the buffer and gets it ready to play.
    /// Otherwise it just sets the edit points and enables the fader if the region
    /// has fade in or out applied to it.
    @objc public func preroll(from startingTime: Double = 0, to endingTime: Double = 0) {
        var from = startingTime
        var to = endingTime

        if to == 0 {
            to = duration
        }

        if from > to {
            from = 0
        }
        startTime = from
        endTime = to

        if isBuffered {
            updateBuffer()
        }

        if isFaded, !isBufferFaded {
            // make sure the fader has been enabled
            super.startFader()
        } else {
            // if there are no fades, be sure to reset this
            super.resetFader()
        }
    }
}

// MARK: - Main Playback Options

extension AKPlayer {
    internal var useCompletionHandler: Bool {
        return (isLooping && !isBuffered) || completionHandler != nil
    }

    /// Play segments of a file
    @objc public func play(from startingTime: Double, to endingTime: Double = 0) {
        var to = endingTime
        if to == 0 {
            to = endTime
        }
        play(from: startingTime, to: to, at: nil, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future.
    /// If the audioTime is in the past it will be played now.
    @objc public func play(at audioTime: AVAudioTime?) {
        var audioTime = audioTime

        if let requestedTime = audioTime {
            if requestedTime.isHostTimeValid, requestedTime.hostTime < mach_absolute_time() {
                AKLog("Scheduled time is in the past so playing now...")
                audioTime = nil
            }
        }

        play(at: audioTime, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future with a hostTime reference
    public func play(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        play(from: startTime, to: endTime, at: audioTime, hostTime: hostTime)
    }

    /// Play file using previously set startTime and endTime at some point in the future specified in seconds
    /// with a hostTime reference
    public func play(when scheduledTime: Double, hostTime: UInt64? = nil) {
        play(from: startTime, to: endTime, when: scheduledTime, hostTime: hostTime)
    }

    public func play(from startingTime: Double,
                     to endingTime: Double,
                     when scheduledTime: Double,
                     hostTime: UInt64? = nil) {
        let refTime = hostTime ?? mach_absolute_time()
        var avTime: AVAudioTime?

        if renderingMode == .offline {
            let sampleTime = AVAudioFramePosition(scheduledTime * sampleRate)
            let sampleAVTime = AVAudioTime(hostTime: refTime, sampleTime: sampleTime, atRate: sampleRate)
            avTime = sampleAVTime
        } else {
            avTime = AVAudioTime(hostTime: refTime).offset(seconds: scheduledTime)
        }

        play(from: startingTime, to: endingTime, at: avTime, hostTime: refTime)
    }

    @objc public func pause() {
        pauseTime = currentTime
        stop()
    }

    @objc public func resume() {
        // save the last set startTime as resume will overwrite it
        let previousStartTime = startTime

        var time = pauseTime ?? 0

        // bounds check
        if time >= duration {
            time = 0
        }
        // clear the frame count in the player
        playerNode.stop()
        play(from: time)

        // restore that startTime as it might be a selection
        startTime = previousStartTime
        // restore the pauseTime cleared by play and preserve it by setting _isPaused to false manually
        pauseTime = time
        isPaused = false
    }

    /// Provides a convenience method for a quick fade out for when a user presses stop.
    public func fadeOutAndStop(time: TimeInterval) {
        guard isPlaying else { return }

        // creates if necessary only
        startFader()

        // Provides a convenience for a quick fade out when a user presses stop.
        // Only do this if it's realtime playback, as Timers aren't running
        // anyway offline.
        if time > 0 && renderingMode == .realtime {
            AKLog("starting stopEnvelopeTime fade of \(time)")

            // stop after an auto fade out
            super.fadeOut(with: time)
            stopEnvelopeTimer?.invalidate()
            stopEnvelopeTimer = Timer.scheduledTimer(timeInterval: time,
                                                     target: self,
                                                     selector: #selector(autoFadeOutCompletion),
                                                     userInfo: nil,
                                                     repeats: false)

        } else {
            stopCompletion()
        }
    }

    @objc private func autoFadeOutCompletion() {
        playerNode.stop()
        super.faderNode?.parameterAutomation?.stopPlayback()
        isPlaying = false
    }

    @objc internal func stopCompletion() {
        guard isPlaying else { return }
        playerNode.stop()
        if isFaded {
            super.faderNode?.parameterAutomation?.stopPlayback()
        }
        isPlaying = false
    }

    // MARK: - Scheduling

    internal func schedulePlayer(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        var scheduleTime = audioTime

        if _rate != 1, let audioTime = audioTime {
            let refTime = hostTime ?? mach_absolute_time()

            if audioTime.isSampleTimeValid {
                // offline
                let adjustedFrames = Double(audioTime.sampleTime) * _rate
                scheduleTime = AVAudioTime(hostTime: refTime,
                                           sampleTime: AVAudioFramePosition(adjustedFrames),
                                           atRate: sampleRate)

            } else if audioTime.isHostTimeValid {
                // realtime
                let adjustedFrames = (audioTime.toSeconds(hostTime: refTime) * _rate) * sampleRate
                scheduleTime = AVAudioTime(hostTime: refTime,
                                           sampleTime: AVAudioFramePosition(adjustedFrames),
                                           atRate: sampleRate)
            }
        }
        if isBuffered {
            scheduleBuffer(at: scheduleTime)
        } else {
            scheduleSegment(at: scheduleTime)
        }
    }

    private func scheduleBuffer(at audioTime: AVAudioTime?) {
        guard let buffer = buffer else { return }

        if playerNode.outputFormat(forBus: 0) != buffer.format {
            initialize()
        }

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts]

        if isLooping, buffering == .always {
            bufferOptions = [.loops, .interrupts]
        }

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            playerNode.scheduleBuffer(buffer,
                                      at: audioTime,
                                      options: bufferOptions,
                                      completionCallbackType: .dataRendered,
                                      completionHandler: useCompletionHandler ? handleCallbackComplete : nil)
        } else {
            // Fallback on earlier version
            playerNode.scheduleBuffer(buffer,
                                      at: audioTime,
                                      options: bufferOptions,
                                      completionHandler: nil) // these completionHandlers are inaccurate pre 10.13
        }

        playerNode.prepare(withFrameCount: buffer.frameLength)
    }

    // play from disk rather than ram
    private func scheduleSegment(at audioTime: AVAudioTime?) {
        guard let audioFile = audioFile else { return }

        let startFrame = AVAudioFramePosition(startTime * audioFile.fileFormat.sampleRate)
        var endFrame = AVAudioFramePosition(endTime * audioFile.fileFormat.sampleRate)

        if endFrame == 0 {
            endFrame = audioFile.length
        }

        let totalFrames = (audioFile.length - startFrame) - (audioFile.length - endFrame)
        guard totalFrames > 0 else {
            AKLog("Unable to schedule file. totalFrames to play: \(totalFrames). audioFile.length: \(audioFile.length)")
            return
        }

        frameCount = AVAudioFrameCount(totalFrames)

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            playerNode.scheduleSegment(audioFile,
                                       startingFrame: startFrame,
                                       frameCount: frameCount,
                                       at: audioTime,
                                       completionCallbackType: .dataRendered, // .dataPlayedBack,
                                       completionHandler: useCompletionHandler ? handleCallbackComplete : nil)
        } else {
            // Fallback on earlier version
            playerNode.scheduleSegment(audioFile,
                                       startingFrame: startFrame,
                                       frameCount: frameCount,
                                       at: audioTime,
                                       completionHandler: nil) // these completionHandlers are inaccurate pre 10.13
        }

        playerNode.prepare(withFrameCount: frameCount)
    }

    // MARK: - Completion Handlers

    @available(iOS 11, macOS 10.13, tvOS 11, *)
    @objc internal func handleCallbackComplete(completionType: AVAudioPlayerNodeCompletionCallbackType) {
        // only forward the completion if is actually done playing without user intervention.

        // it seems to be unstable having any outbound calls from this callback not be sent to main?
        DispatchQueue.main.async {
            // reset the loop if user stopped it
            if self.isLooping, self.buffering == .always {
                self.startTime = self.loop.start
                self.endTime = self.loop.end
                self.pauseTime = nil
                return
            }
            do {
                try AKTry {
                    // if the user calls stop() themselves then the currentFrame will be 0 as of 10.14
                    // in this case, don't call the completion handler
                    if self.currentFrame > 0 {
                        self.handleComplete()
                    }
                }
            } catch {
                AKLog("Failed to check currentFrame and call completion handler: \(error)... ",
                      "Possible Media Service Reset?")
            }
        }
    }

    @objc private func handleComplete() {
        stop()
        super.faderNode?.parameterAutomation?.stopPlayback()

        if isLooping {
            startTime = loop.start
            endTime = loop.end
            play()
            loopCompletionHandler?()
            return
        }
        if pauseTime != nil {
            startTime = 0
            pauseTime = nil
        }

        completionHandler?()
    }
}

@objc extension AKPlayer: AKTiming {
    public func start(at audioTime: AVAudioTime?) {
        play(at: audioTime)
    }

    public var isStarted: Bool {
        return isPlaying
    }

    public func setPosition(_ position: Double) {
        startTime = position
        if isPlaying {
            stop()
            play()
        }
    }

    public func position(at audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return startTime
        }
        return startTime + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    public func audioTime(at position: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (position - startTime) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    open func prepare() {
        preroll(from: startTime, to: endTime)
    }
}
