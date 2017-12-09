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
        if player?.isLooping ?? false {
            return
        }
        playButton.state = .off
        playButton.title = "▶️"
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
        guard player != nil else { return }
        player!.completionHandler = handleAudioComplete
        internalManager!.connectEffects(firstNode: player, lastNode: mixer)
        player!.isLooping = loopButton.state == .on
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
        guard player != nil else { return }
        waveform?.position = player!.currentTime
        updateTimeDisplay(player!.currentTime)
    }

    internal func updateTimeDisplay(_ time: Double) {
        timeField.stringValue = AKPlayer.formatSeconds(time)
    }

}

extension AudioUnitManager: AKWaveformDelegate {
    func loopChanged(source: AKWaveform) {
        player?.loop.start = source.loopStart
        player?.loop.end = source.loopEnd
        player?.endTime = source.loopEnd
        player?.startTime = source.loopStart
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
        audioPlaying = player?.isPlaying ?? false
        stopAudioTimer()
        player?.stop()
        updateTimeDisplay(time)
    }
}
