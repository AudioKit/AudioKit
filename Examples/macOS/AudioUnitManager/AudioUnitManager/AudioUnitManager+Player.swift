//
//  AudioUnitManager+Player.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AudioKit
import Cocoa

extension AudioUnitManager {
    internal func handlePlay(state: Bool) {
        guard let player = player else { return }
        // stop
        if player.isPlaying {
            player.pause()
        }

        playButton.state = state ? .on : .off

        if state {
            // play

            // just turning off the synths if they are playing
            if fmOscillator.isStarted {
                fmButton?.state = .off
                fmOscillator.stop()
            }

            if auInstrument != nil {
                instrumentPlayButton.state = .off
            }

            // then attach the effects chain if needed
            if internalManager.input != player {
                internalManager.connectEffects(firstNode: player, lastNode: mixer)
            }
            startEngine(completionHandler: {
                player.volume = 1

                player.play(from: self.waveform?.position ?? 0)
                self.startAudioTimer()
            })
        } else {
            if AudioKit.engine.isRunning {
                // just turns off reverb tails or delay lines etc
                internalManager.reset()
            }
            stopAudioTimer()
        }
    }

    func handleRewind() {
        guard let player = player else { return }
        let wasPlaying = player.isPlaying
        if wasPlaying {
            handlePlay(state: false)
        }

        player.startTime = 0
        waveform?.position = 0
        updateTimeDisplay(0)

        if wasPlaying {
            DispatchQueue.main.async {
                self.handlePlay(state: true)
            }
        }
    }

    func handleAudioComplete() {
        guard let player = player else { return }
        // AKLog("handleAudioComplete()")

        handlePlay(state: false)
        player.startTime = 0
        handleRewindButton(rewindButton)
    }

    /// open an audio URL for playing
    func open(url: URL) {
        try? AudioKit.stop()

        peak = nil

        if player == nil {
            player = AKPlayer(url: url)
        } else {
            do {
                handlePlay(state: false)
                try player?.load(url: url)
            } catch {}
        }
        guard let player = player else { return }
        player.completionHandler = handleAudioComplete
        internalManager.connectEffects(firstNode: player, lastNode: mixer)
        player.isLooping = isLooping
        player.isNormalized = false
        player.buffering = isBuffered ? .always : .dynamic

        playButton.isEnabled = true
        fileField.stringValue = "🔈 \(url.lastPathComponent)"

        waveform?.dispose()

        // get the waveform
        let darkRed = NSColor(calibratedRed: 0.79, green: 0.128, blue: 0.06, alpha: 1)
        waveform = AKWaveform(url: url, color: darkRed)

        guard let waveform = waveform else { return }

        waveformContainer.addSubview(waveform)
        waveform.frame = waveformContainer.frame
        waveform.fitToFrame()
        waveform.delegate = self
        audioEnabled = true

        audioNormalizedButton.state = .off
    }

    func close() {
        fileField.stringValue = ""
        waveform?.dispose()
        player?.detach()
        player = nil
        audioEnabled = false
    }

    // this just moves the Timeline bar in the waveform
    internal func startAudioTimer() {
        stopAudioTimer()
        audioTimer = Timer.scheduledTimer(timeInterval: 0.02,
                                          target: self,
                                          selector: #selector(AudioUnitManager.updateWaveformDisplay),
                                          userInfo: nil,
                                          repeats: true)
    }

    internal func stopAudioTimer() {
        if audioTimer?.isValid ?? false {
            audioTimer?.invalidate()
        }
    }

    @objc private func updateWaveformDisplay() {
        guard let player = player else { return }
        // AKLog("\(player.currentTime)")
        waveform?.position = player.currentTime
        updateTimeDisplay(player.currentTime)
    }

    internal func updateTimeDisplay(_ time: Double) {
        timeField.stringValue = String.toClock(time)
    }
}

extension AudioUnitManager: AKWaveformDelegate {
    func loopChanged(source: AKWaveform) {
        guard let player = player else { return }
        let wasPlaying = player.isPlaying
        if wasPlaying {
            handlePlay(state: false)
        }

        player.loop.start = source.loopStart
        player.loop.end = source.loopEnd
        player.endTime = source.loopEnd
        player.startTime = source.loopStart

        if wasPlaying {
            handlePlay(state: true)
        }
    }

    func waveformScrubbed(source: AKWaveform, at time: Double) {
        updateTimeDisplay(time)
    }

    func waveformScrubComplete(source: AKWaveform, at time: Double) {
        if audioPlaying {
            handlePlay(state: true)
        } else {
            player?.startTime = time
        }
        updateTimeDisplay(time)
    }

    func waveformSelected(source: AKWaveform, at time: Double) {
        guard let player = player else { return }

        audioPlaying = player.isPlaying
        handlePlay(state: false)
        updateTimeDisplay(time)
    }
}
