//
//  PlayerDemoViewController.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/26/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

class PlayerDemoViewController: NSViewController {
    @IBOutlet var playButton: NSButton!
    @IBOutlet var pathControl: NSPathControl!
    @IBOutlet var waveformView: WaveformView!

    var player: AKDynamicPlayer?
    lazy var mixer = AKMixer()

    lazy var openPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.appearance = view.window?.appearance
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["aac", "caf", "aif", "aiff",
                                  "aifc", "m4v", "mov", "mp3",
                                  "mp4", "m4a", "snd", "au",
                                  "sd2", "wav"]
        return panel
    }()

    convenience init() {
        self.init(nibName: "PlayerDemoViewController", bundle: Bundle.main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pathControl?.delegate = self
        if let url = Bundle.main.resourceURL?.appendingPathComponent("PinkNoise.wav") {
            open(url: url)
        }

        AKSettings.sampleRate = 48000 // arbritary, but PinkNoise is 48k

        // setup signal chain
        AKManager.output = mixer
    }

    @IBAction func handleChooseButton(_ sender: NSButton) {
        guard let window = view.window else { return }

        openPanel.beginSheetModal(for: window) { response in
            if response == .OK, let url = self.openPanel.url {
                self.open(url: url)
            }
        }
    }

    @IBAction func handlePlayButton(_ sender: NSButton) {
        let state = sender.state == .on
        state ? play() : stop()
    }

    func open(url: URL) {
        pathControl?.url = url

        if player != nil {
            player?.disconnectOutput()
            player?.detach()
            player = nil
        }

        guard let audioFile = try? AVAudioFile(forReading: url) else {
            AKLog("Failed to open", url, type: .error)
            return
        }

        let player = AKDynamicPlayer(audioFile: audioFile)
        player >>> mixer
        self.player = player

        waveformView?.open(audioFile: audioFile)
    }

    func play() {
        if !AKManager.engine.isRunning {
            try? AKManager.start()
            delayed(by: 1, closure: {
                self.handlePlay()
            })
            return
        }

        handlePlay()
    }

    private func handlePlay() {
        AKLog("▶️")

        player?.play(from: 0, to: 0, when: 0, hostTime: nil)
    }

    func stop() {
        AKLog("⏹")
        player?.stop()
    }
}

extension PlayerDemoViewController: NSPathControlDelegate {}

func delayed(by delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
