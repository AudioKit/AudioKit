//
//  AKPlayer+Playback.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

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
        super.faderNode?.stopAutomation()
        isPlaying = false
    }

    @objc internal func stopCompletion() {
        guard isPlaying else { return }
        playerNode.stop()
        if isFaded {
            super.faderNode?.stopAutomation()
        }
        isPlaying = false
    }

    // MARK: - Scheduling

    internal func schedulePlayer(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        var scheduleTime = audioTime

        if _rate != 1, let audioTime = audioTime {
            let refTime = hostTime ?? mach_absolute_time()

            if audioTime.isSampleTimeValid {
                let adjustedFrames = Double(audioTime.sampleTime) * _rate
                scheduleTime = AVAudioTime(hostTime: refTime,
                                           sampleTime: AVAudioFramePosition(adjustedFrames),
                                           atRate: sampleRate)

            } else if audioTime.isHostTimeValid {
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

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts] // isLooping ? [.loops, .interrupts] : [.interrupts]

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
            AKLog("Unable to schedule file. totalFrames to play is \(totalFrames). audioFile.length is \(audioFile.length)")
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
                AKLog("Failed to check currentFrame and call completion handler: \(error)... Possible Media Service Reset?")
            }
        }
    }

    @objc private func handleComplete() {
        stop()
        super.faderNode?.stopAutomation()

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
