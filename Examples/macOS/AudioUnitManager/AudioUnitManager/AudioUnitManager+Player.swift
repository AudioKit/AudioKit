//
//  ViewControllerAudio.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 12/8/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import Cocoa
import AudioKit

extension AudioUnitManager {

    func handleAudioComplete() {
        guard let player = player else { return }
        Swift.print("handleAudioComplete()")

        if player.isLooping {
            return
        } else {
            player.startTime = 0
            handlePlayButton(playButton)
            handleRewindButton(rewindButton)
        }
    }

    /// open an audio URL for playing
    func open(url: URL) {
        guard internalManager != nil else { return }
        guard mixer != nil else { return }

        if player == nil {
            player = AKPlayer(url: url)
        } else {
            do {
                try player?.load(url: url)
            } catch {}
        }
        guard let player = player else { return }
        player.completionHandler = handleAudioComplete
        internalManager!.connectEffects(firstNode: player, lastNode: mixer)
        player.isLooping = loopButton.state == .on

        playButton.isEnabled = true
        fileField.stringValue = "🔈 \(url.lastPathComponent)"

        if waveform != nil {
            waveform!.dispose()
        }

        // get the waveform
        let darkRed = NSColor(calibratedRed: 0.79, green: 0.128, blue: 0.06, alpha: 1)
        waveform = AKWaveform(url: url, color: darkRed)
        guard waveform != nil else { return }

        waveformContainer.addSubview(waveform!)
        waveform?.frame = waveformContainer.frame
        waveform?.fitToFrame()
        waveform?.delegate = self

        audioEnabled = true
    }

    func close() {
        fileField.stringValue = ""
        waveform?.dispose()
        player?.disconnect()
        player = nil
        audioEnabled = false
    }

    // this just moves the Timeline bar in the waveform
    internal func startAudioTimer() {
        audioTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                          target: self,
                                          selector: #selector(AudioUnitManager.updateWaveformDisplay),
                                          userInfo: nil,
                                          repeats: true)
    }

    internal func stopAudioTimer() {
        audioTimer?.invalidate()
    }

    @objc private func updateWaveformDisplay() {
        guard let player = player else { return }
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
        player.stop()

        player.loop.start = source.loopStart
        player.loop.end = source.loopEnd
        player.endTime = source.loopEnd
        player.startTime = source.loopStart

        if wasPlaying {
            player.play()
        }
    }

    func waveformScrubbed(source: AKWaveform, at time: Double) {
        updateTimeDisplay(time)
    }

    func waveformScrubComplete(source: AKWaveform, at time: Double) {
        if audioPlaying {
            startAudioTimer()
            player?.play(from: time)
        } else {
            player?.startTime = time
        }
        updateTimeDisplay(time)
    }

    func waveformSelected(source: AKWaveform, at time: Double) {
        guard let player = player else { return }

        audioPlaying = player.isPlaying
        stopAudioTimer()
        player.stop()
        updateTimeDisplay(time)
    }
}
