// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
            if internalManager.input !== player {
                internalManager.connectEffects(firstNode: player, lastNode: mixer)
            }
            startEngine {
                player.volume = 1
                player.play(from: self.waveform?.position ?? 0)
                self.startAudioTimer()
            }
        } else {
            if engine.isRunning {
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
        try? engine.stop()
        handlePlay(state: false)

        if player == nil {
            createPlayer(url: url)

        } else {
            do {
                try player?.load(url: url)
            } catch let err as NSError {
                AKLog(err)
                createPlayer(url: url)
            }
        }

        playButton.isEnabled = true
        fileField.stringValue = "🔈 \(url.lastPathComponent)"

        if waveform != nil {
            waveform?.dispose()
        }

        // create the waveform
        waveform = WaveformView(url: url,
                                color: NSColor(calibratedRed: 0.79, green: 0.372, blue: 0.191, alpha: 1))

        guard let waveform = waveform else { return }

        waveformContainer.addSubview(waveform)
        waveform.frame = waveformContainer.frame
        waveform.fitToFrame()
        waveform.delegate = self
        audioEnabled = true
        audioNormalizedButton.state = .off
    }

    private func createPlayer(url: URL) {
        if player != nil {
            player?.detach()
            player = nil
        }

        player = AKPlayer(url: url)
        player?.completionHandler = handleAudioComplete
        player?.isLooping = isLooping
        player?.isNormalized = isNormalized
        player?.buffering = isBuffered ? .always : .dynamic

        internalManager.connectEffects(firstNode: player, lastNode: mixer)
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

extension AudioUnitManager: WaveformViewDelegate {
    func loopChanged(source: WaveformView) {
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

    func waveformScrubbed(source: WaveformView, at time: Double) {
        updateTimeDisplay(time)
    }

    func waveformScrubComplete(source: WaveformView, at time: Double) {
        if audioPlaying {
            handlePlay(state: true)
        } else {
            player?.startTime = time
        }
        updateTimeDisplay(time)
    }

    func waveformSelected(source: WaveformView, at time: Double) {
        guard let player = player else { return }

        audioPlaying = player.isPlaying
        handlePlay(state: false)
        updateTimeDisplay(time)
    }
}
