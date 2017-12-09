//
//  ViewControllerAudio.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 12/8/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import Cocoa
import AudioKit

extension ViewController {
    @IBAction func handleLoopButton(_ sender: NSButton) {
        let state = sender.state == .on
        sender.title = state ? "🔁" : "🔄"
        player?.isLooping = state
        waveform?.isLooping = state
    }
    
    @IBAction func chooseAudio(_ sender: Any) {
        
        guard let window = view.window else { return }
        AKLog("chooseAudio()")
        if openPanel == nil {
            openPanel = NSOpenPanel()
            openPanel!.message = "Open Audio File"
            openPanel!.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]
        }
        
        openPanel!.beginSheetModal( for: window, completionHandler: { response in
            if response.rawValue == NSFileHandlingPanelOKButton {
                if let url = self.openPanel?.url {
                    self.open(url: url)
                }
            }
        })
    }
    
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
        
        player = AKPlayer(url: url)
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
    }
    
    @IBAction func handlePlayButton(_ sender: Any) {
        guard let player = player else { return }
        
        if fm != nil && fm!.isStarted {
            fmButton!.state = .off
            fm!.stop()
        }
        
        if auInstrument != nil {
            instrumentPlayButton.title = "▶️"
        }
        
        if playButton.title == "⏹" {
            player.stop()
            playButton.title = "▶️"
            
            if AudioKit.engine.isRunning {
                AudioKit.stop()
                internalManager?.reset()
            }
            
            stopAudioTimer()
            
        } else {
            if !AudioKit.engine.isRunning {
                AudioKit.start()
            }
            
            if internalManager?.input != player {
                internalManager!.connectEffects(firstNode: player, lastNode: mixer)
            }
            player.volume = 1
            player.play(from: waveform?.position ?? 0)
            playButton.title = "⏹"
            startAudioTimer()
            
        }
    }
    
    // this just moves the Timeline bar in the waveform
    private func startAudioTimer() {
        audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateWaveformDisplay), userInfo: nil, repeats: true)
    }
    
    private func stopAudioTimer() {
        audioTimer?.invalidate()
    }
    
    @objc private func updateWaveformDisplay() {
        guard player != nil else { return }
        waveform?.position = player!.currentTime
    }
    
}

extension ViewController: AKWaveformDelegate {
    
    func loopChanged(source: AKWaveform) {
        player?.loop.start = source.loopStart
        player?.loop.end = source.loopEnd

        player?.endTime = source.loopEnd
        player?.startTime = source.loopStart
    }
    
    func waveformScrubbed(source: AKWaveform, at time: Double) {
        
    }
    
    func waveformScrubComplete(source: AKWaveform, at time: Double) {
        if audioPlaying {
            startAudioTimer()
            player?.play(from: time)
        } else {
            player?.startTime = time
        }
    }
    
    func waveformSelected(source: AKWaveform, at time: Double) {
        audioPlaying = player?.isPlaying ?? false
        stopAudioTimer()
        player?.stop()
    }
}
