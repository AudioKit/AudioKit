//
//  ViewController.swift
//  macOSDevelopment
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa

// If you make changes to this class, either don't commit them, or make sure you don't break the exisiting setup.
class ViewController: NSViewController {
    @IBOutlet var startButton: NSButton!

    @IBOutlet var playerBox: NSBox!

    // Default controls
    @IBOutlet var playButton: NSButton!
    @IBOutlet var sliderLabel2: NSTextField!

    @IBOutlet var slider3: NSSlider!
    @IBOutlet var slider3Value: NSTextField!

    @IBOutlet var gainSlider: NSSlider!
    @IBOutlet var gainValue: NSTextField!
    @IBOutlet var rateSlider: NSSlider!
    @IBOutlet var rateValue: NSTextField!

    @IBOutlet var pitchSlider: NSSlider!
    @IBOutlet var pitchValue: NSTextField!

    @IBOutlet var fadeInSlider: NSSlider!
    @IBOutlet var fadeInValue: NSTextField!
    @IBOutlet var fadeOutSlider: NSSlider!
    @IBOutlet var fadeOutValue: NSTextField!

    @IBOutlet var chooseAudioButton: NSButton!
    @IBOutlet var inputSourceInfo: NSTextField!

    @IBOutlet var loopButton: NSButton!
    @IBOutlet var reverseButton: NSButton!

    @IBOutlet var pauseButton: NSButton!

    var openPanel = NSOpenPanel()

    var audioTitle: String {
        guard let av = player?.audioFile else { return "" }
        return av.url.lastPathComponent
    }

    // Define components ⏦ ⏚ ⎍ ⍾ ⚙︎
    var osc = AKOscillator()
    var speechSynthesizer = AKSpeechSynthesizer()
    var mixer = AKMixer()
    var player: AKDynamicPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.appearance = NSAppearance(named: .vibrantDark)

        // osc.start()
        osc.frequency = 220
        osc.amplitude = 1
        osc.rampDuration = 0.0

        osc >>> mixer
        speechSynthesizer >>> mixer

        AudioKit.output = mixer

        openPanel.message = "Open Audio File"
        openPanel.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]

        start(startButton)

        if let url = Bundle.main.url(forResource: "PinkNoise", withExtension: "wav") {
            open(url: url)
        }
    }

    @IBAction func start(_ sender: NSButton) {
        var state = AudioKit.engine.isRunning

        do {
            if state {
                try AudioKit.stop()
            } else {
                try AudioKit.start()
            }
            state = AudioKit.engine.isRunning
            sender.state = state ? .on : .off
        } catch {
            AKLog("ERROR: AudioKit did not start.")
        }

        guard let content = playerBox.contentView else { return }
        for sv in content.subviews {
            guard let control = sv as? NSControl else { continue }
            control.isEnabled = state
        }

        playButton.isEnabled = state
        startButton.title = state ? "Stop Engine" : "Start Engine"

    }

    private func initPlayer() {
        if player == nil, let chooseAudioButton = chooseAudioButton {
            chooseAudio(chooseAudioButton)
            return
        }
        guard let player = player else { return }

        // booster.disconnectInput()
        player >>> mixer

        handleUpdateParam(gainSlider)
        handleUpdateParam(rateSlider)
        handleUpdateParam(pitchSlider)
        handleUpdateParam(fadeInSlider)
        handleUpdateParam(fadeOutSlider)
    }

    @IBAction func chooseAudio(_ sender: Any) {
        guard let window = view.window else { return }
        openPanel.beginSheetModal(for: window, completionHandler: { response in
            if response == NSApplication.ModalResponse.OK {
                if let url = self.openPanel.url {
                    self.open(url: url)
                }
            }
        })
    }

    @IBAction func setLoopState(_ sender: NSButton) {
        player?.isLooping = sender.state == .on
    }

    @IBAction func setPauseState(_ sender: NSButton) {
        guard let player = player else { return }

        let state = sender.state == .on

        if state {
            player.pause()
            AKLog("set pause start time to", player.pauseTime ?? 0.0)
        } else {
            player.resume()
        }
    }

    @IBAction func setReversedState(_ sender: NSButton) {
        let state = sender.state == .on
        player?.isReversed = state
    }

    @IBAction func setBufferedState(_ sender: NSButton) {
        let state = sender.state == .on

        player?.buffering = state ? .always : .dynamic
    }

    /// open an audio URL for playing
    func open(url: URL) {
        inputSourceInfo.stringValue = url.lastPathComponent

        // for now just make a new player so it's not necessary to rebalance format types
        // if the processingFormat changes
        if player != nil {
            player?.detach()
            player = nil
        }

        AKLog("Creating player...", url)
        player = AKDynamicPlayer(url: url)
        player?.completionHandler = handleAudioComplete
        player?.isLooping = loopButton.state == .on
        player?.createFader()
        initPlayer()

        AKLog("Opened", url.path, "duration", player?.duration)
    }

    @IBAction func handleOscillator(_ sender: NSButton) {
        let state = sender.state == .on
        state ? osc.play() : osc.stop()
    }

    @IBAction func handleSpeech(_ sender: NSButton) {
        speechSynthesizer.say(text: "Hello There")
    }

    @IBAction func handlePlayer(_ sender: NSButton) {
        let state = sender.state == .on

        guard let player = player else {
            return
        }

        // play in X seconds
        state ? player.play(when: 0) : player.fadeOutAndStop(time: 0.5)

        AKLog("player.isPlaying:", player.isPlaying)
    }

    private func handleAudioComplete() {
        AKLog("Complete")
        guard let player = player else { return }
        if !player.isLooping {
            playButton?.state = .off
            player.stop()
        }
    }

    @IBAction func handleUpdateParam(_ sender: NSSlider) {
        guard let player = player else {
            AKLog("Player faderNode is nil")
            return
        }
        if sender == gainSlider {
            let dB = gainSlider.doubleValue
            let gain = pow(10.0, dB / 20.0)

            let plus = dB > 0 ? "+" : ""
            gainSlider.stringValue = "\(plus)\(roundTo(dB, decimalPlaces: 1)) dB"
            player.gain = gain
        } else if sender == rateSlider {
            player.rate = rateSlider.doubleValue
            rateValue.stringValue = String(describing: roundTo(rateSlider.doubleValue, decimalPlaces: 3))

        } else if sender == pitchSlider {
            player.pitch = pitchSlider.doubleValue
            pitchValue.stringValue = String(describing: roundTo(pitchSlider.doubleValue, decimalPlaces: 1))

        } else if sender == fadeInSlider {
            player.fade.inTime = fadeInSlider.doubleValue
            fadeInValue.stringValue = String(describing: roundTo(fadeInSlider.doubleValue, decimalPlaces: 3))

        } else if sender == fadeOutSlider {
            player.fade.outTime = fadeInSlider.doubleValue
            fadeOutValue.stringValue = String(describing: roundTo(fadeOutSlider.doubleValue, decimalPlaces: 3))

            // Currently unused
        } else if sender == slider3 {
            let value = Int(slider3.intValue)
            if value == AKSettings.RampType.linear.rawValue {
                player.fade.inRampType = .linear
                player.fade.outRampType = .linear
                slider3Value.stringValue = "Linear"

            } else if value == AKSettings.RampType.exponential.rawValue {
                player.fade.inRampType = .exponential
                player.fade.outRampType = .exponential

                slider3Value.stringValue = "Exponential"

            } else if value == AKSettings.RampType.logarithmic.rawValue {
                player.fade.inRampType = .logarithmic
                player.fade.outRampType = .logarithmic

                slider3Value.stringValue = "Logarithmic"

            } else if value == AKSettings.RampType.sCurve.rawValue {
                player.fade.inRampType = .sCurve
                player.fade.outRampType = .sCurve

                slider3Value.stringValue = "S Curve"
            }
        }
    }

    private func roundTo(_ value: Double, decimalPlaces: Int) -> Double {
        let decimalValue = pow(10.0, Double(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }
}
