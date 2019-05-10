//
//  AKPlayer+Playback.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 6/12/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension AKPlayer {
    /// Play entire file right now
    @objc public func play() {
        play(from: startTime, to: endTime, at: nil, hostTime: nil)
    }

    /// Play segments of a file
    @objc public func play(from startingTime: Double, to endingTime: Double = 0) {
        var to = endingTime
        if to == 0 {
            to = endTime
        }
        play(from: startingTime, to: to, at: nil, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future
    @objc public func play(at audioTime: AVAudioTime?) {
        play(at: audioTime, hostTime: nil)
    }

    /// Play file using previously set startTime and endTime at some point in the future with a hostTime reference
    public func play(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        play(from: startTime, to: endTime, at: audioTime, hostTime: hostTime)
    }

    /// Play file using previously set startTime and endTime at some point in the future specified in seconds
    /// with a hostTime reference
    public func play(when scheduledTime: Double, hostTime: UInt64?) {
        play(from: startTime, to: endTime, when: scheduledTime, hostTime: hostTime)
    }

    public func play(from startingTime: Double,
                     to endingTime: Double,
                     when scheduledTime: Double,
                     hostTime: UInt64? = nil) {
        let refTime = hostTime ?? mach_absolute_time()
        let avTime = AVAudioTime.secondsToAudioTime(hostTime: refTime, time: scheduledTime)

        // Note, final play command is in AKPlayer.swift for subclass override
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
        _isPaused = false
    }

    /// Stop playback and cancel any pending scheduled playback or completion events
    @objc public func stop() {
        guard isPlaying else {
            // AKLog("Player isn't playing")
            return
        }
        guard stopEnvelopeTime > 0 else {
            // stop immediately
            stopCompletion()
            return
        }

        // AKLog("starting stopEnvelopeTime fade of", stopEnvelopeTime)

        // stop after an auto fade out
        fadeOutWithTime(stopEnvelopeTime)
        faderTimer?.invalidate()
        faderTimer = Timer.scheduledTimer(timeInterval: stopEnvelopeTime,
                                          target: self,
                                          selector: #selector(stopCompletion),
                                          userInfo: nil,
                                          repeats: false)
    }

    @objc private func stopCompletion() {
        playerNode.stop()
        faderNode?.stop()
        completionTimer?.invalidate()
        prerollTimer?.invalidate()
        faderTimer?.invalidate()
    }

    // MARK: - Scheduling

    // NOTE to maintainers: these timers can be removed when AudioKit is built for 10.13.
    // in that case the AVFoundation completion handlers of the scheduling can be used.
    // Pre 10.13, the completion handlers are inaccurate to the point of unusable.

    // if the file is scheduled, start a timer to determine when to start the completion timer
    private func startPrerollTimer(_ prerollTime: Double) {
        DispatchQueue.main.async {
            self.prerollTimer?.invalidate()
            self.prerollTimer = Timer.scheduledTimer(timeInterval: prerollTime,
                                                     target: self,
                                                     selector: #selector(self.startCompletionTimer),
                                                     userInfo: nil,
                                                     repeats: false)
        }
    }

    // keep this timer separate in the cases of sounds that aren't scheduled
    @objc private func startCompletionTimer() {
        var segmentDuration = endTime - startTime
        if isLooping && loop.end > 0 {
            segmentDuration = loop.end - startTime
        }

        DispatchQueue.main.async {
            self.completionTimer?.invalidate()
            self.completionTimer = Timer.scheduledTimer(timeInterval: segmentDuration,
                                                        target: self,
                                                        selector: #selector(self.handleComplete),
                                                        userInfo: nil,
                                                        repeats: false)
        }
    }

    internal func schedule(at audioTime: AVAudioTime?, hostTime: UInt64?) {
        if isBuffered {
            scheduleBuffer(at: audioTime)
        } else {
            scheduleSegment(at: audioTime)
        }

        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            // nothing further is needed as the completion is specified in the scheduler
        } else {
            completionTimer?.invalidate()
            prerollTimer?.invalidate()

            if let audioTime = audioTime, let hostTime = hostTime {
                let prerollTime = audioTime.toSeconds(hostTime: hostTime)
                startPrerollTimer(prerollTime)
            } else {
                startCompletionTimer()
            }
        }
    }

    private func scheduleBuffer(at audioTime: AVAudioTime?) {
        guard let buffer = buffer else { return }

        if playerNode.outputFormat(forBus: 0) != buffer.format {
            initialize()
        }

        var bufferOptions: AVAudioPlayerNodeBufferOptions = [.interrupts] // isLooping ? [.loops, .interrupts] : [.interrupts]

        if isLooping && buffering == .always {
            bufferOptions = [.loops, .interrupts]
        }

        // AKLog("Scheduling buffer...\(startTime) to \(endTime)")
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
            AKLog("Unable to schedule file. totalFrames to play is \(totalFrames). audioFile.length is", audioFile.length)
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

    // this will be the method in the scheduling completionHandler >= 10.13
    @available(iOS 11, macOS 10.13, tvOS 11, *)
    @objc internal func handleCallbackComplete(completionType: AVAudioPlayerNodeCompletionCallbackType) {
        // AKLog("\(audioFile?.url.lastPathComponent ?? "?") currentFrame:\(currentFrame) totalFrames:\(frameCount) currentTime:\(currentTime)/\(duration)")
        // only forward the completion if is actually done playing without user intervention.

        // it seems to be unstable having any outbound calls from this callback not be sent to main?
        DispatchQueue.main.async {
            // cancel any upcoming fades
            self.faderTimer?.invalidate()

            // reset the loop if user stopped it
            if self.isLooping && self.buffering == .always {
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
            } catch let error {
                AKLog("Failed to check currentFrame and call completion handler: \(error)... Possible Media Service Reset?")
            }
        }
    }

    @objc private func handleComplete() {
        stop()
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
        // AKLog("Firing callback. currentFrame:", currentFrame, "frameCount:", frameCount)

        completionHandler?()
    }
}
