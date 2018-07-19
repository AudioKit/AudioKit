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
    @IBOutlet var inputSourceBox: NSBox!

    // Default controls
    @IBOutlet var playButton: NSButton!
    @IBOutlet var sliderLabel1: NSTextField!
    @IBOutlet var slider1: NSSlider!
    @IBOutlet var sliderLabel2: NSTextField!
    @IBOutlet var slider2: NSSlider!
    @IBOutlet var slider1Value: NSTextField!
    @IBOutlet var slider2Value: NSTextField!
    @IBOutlet var slider3: NSSlider!
    @IBOutlet var sliderLabel3: NSTextField!
    @IBOutlet var slider3Value: NSTextField!
    @IBOutlet var inputSource: NSPopUpButton!
    @IBOutlet var chooseAudioButton: NSButton!
    @IBOutlet var inputSourceInfo: NSTextField!

    @IBOutlet var loopButton: NSButton!
    @IBOutlet var reverseButton: NSButton!
    @IBOutlet var normalizeButton: NSButton!

    var openPanel: NSOpenPanel?

    var audioTitle: String {
        guard let av = player?.audioFile else { return "" }
        return av.url.lastPathComponent
    }

    // Define components ⏦ ⏚ ⎍ ⍾ ⚙︎
    var osc = AKOscillator()
    var speechSynthesizer = AKSpeechSynthesizer()
    var booster = AKBooster()
    var player: AKPlayer?
    var node: AKNode? {
        didSet {
            updateEnabled()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        booster.gain = slider1.doubleValue

        osc.start()
        osc.frequency = 220
        osc.amplitude = 1
        osc.rampDuration = 0.0
        booster.rampType = .exponential
        AudioKit.output = booster

        handleUpdateParam(slider1)
        handleUpdateParam(slider2)
        handleUpdateParam(slider3)
    }

    @IBAction func start(_ sender: Any) {

        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        guard let content = inputSourceBox.contentView else { return }
        for sv in content.subviews {
            guard let control = sv as? NSControl else { continue }
            control.isEnabled = true
        }

        initOscillator()
    }

    private func updateEnabled() {
        chooseAudioButton.isEnabled = node == player
        loopButton.isEnabled = node == player
        reverseButton.isEnabled = node == player
        normalizeButton.isEnabled = node == player
    }

    private func initOscillator() {
        guard node != osc else { return }
        booster.disconnectInput()
        osc >>> booster
        node = osc
    }

    private func initSpeechSynthesizer() {
        guard node != speechSynthesizer else { return }
        booster.disconnectInput()
        speechSynthesizer >>> booster
        node = speechSynthesizer
    }

    private func initPlayer() {
        if player == nil {
            chooseAudio(chooseAudioButton)
            return
        }
        guard node != player else { return }
        guard let player = player else { return }

        booster.disconnectInput()
        player >>> booster
        node = player
    }

    @IBAction func changeInput(_ sender: NSPopUpButton) {
        guard let title = sender.selectedItem?.title else { return }

        inputSourceInfo.stringValue = title

        if title == "Oscillator" {
            initOscillator()
        } else if title == "SpeechSynthesizer" {
            initSpeechSynthesizer()
        } else if title == "Player" {
            initPlayer()
        }
    }

    @IBAction func chooseSpeechSynthesizer(_ sender: Any) {
        initSpeechSynthesizer()
    }

    @IBAction func chooseAudio(_ sender: Any) {
        guard let window = view.window else { return }
        if openPanel == nil {
            openPanel = NSOpenPanel()
            openPanel!.message = "Open Audio File"
            openPanel!.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]
        }
        guard let openPanel = openPanel else { return }
        openPanel.beginSheetModal(for: window, completionHandler: { response in
            if response == NSApplication.ModalResponse.OK {
                if let url = openPanel.url {
                    self.open(url: url)
                }
            }
        })
    }

    @IBAction func setLoopState(_ sender: NSButton) {
        player?.isLooping = sender.state == .on
    }

    @IBAction func setNormalizeState(_ sender: NSButton) {
        player?.isNormalized = sender.state == .on
    }

    @IBAction func setReversedState(_ sender: NSButton) {
        player?.isReversed = sender.state == .on
    }

    /// open an audio URL for playing
    func open(url: URL) {
        inputSourceInfo.stringValue = url.lastPathComponent

        if player == nil {
            player = AKPlayer(url: url)
            player?.completionHandler = handleAudioComplete
            player?.isLooping = loopButton.state == .on
            // for seamless looping use:
            player?.buffering = .dynamic
            // can use these to test the internal fader in the player:
//            player?.fade.inTime = 1
//            player?.fade.outTime = 1
//            player?.fade.inRampType = .linear
//            player?.fade.outRampType = .exponential
        } else {
            do {
                try player?.load(url: url)
            } catch {}
        }
        initPlayer()

        AKLog("Opened \(url.lastPathComponent)")
    }

    @IBAction func handlePlay(_ sender: NSButton) {
        let state = sender.state == .on
        if node == osc {
            state ? osc.play() : osc.stop()
        } else if node == speechSynthesizer {
//            speechSynthesizer.sayHello()
        } else if node == player {
            state ? player?.resume() : player?.pause()
        }
    }

    private func handleAudioComplete() {
        if !(player?.isLooping ?? false) {
            playButton?.state = .off
        }
    }

    @IBAction func handleUpdateParam(_ sender: NSSlider) {
        if sender == slider1 {
            booster.gain = slider1.doubleValue
            slider1Value.stringValue = String(describing: roundTo(booster.gain, decimalPlaces: 3))

        } else if sender == slider2 {
            booster.rampDuration = slider2.doubleValue
            slider2Value.stringValue = String(describing: roundTo(booster.rampDuration, decimalPlaces: 3))

        } else if sender == slider3 {
            let value = Int(slider3.intValue)
            if value == AKSettings.RampType.linear.rawValue {
                booster.rampType = .linear
                // player?.rampType = .linear
                slider3Value.stringValue = "Linear"

            } else if value == AKSettings.RampType.exponential.rawValue {
                booster.rampType = .exponential
                // player?.rampType = .exponential
                slider3Value.stringValue = "Exponential"

            } else if value == AKSettings.RampType.logarithmic.rawValue {
                booster.rampType = .logarithmic
                slider3Value.stringValue = "Logarithmic"

            } else if value == AKSettings.RampType.sCurve.rawValue {
                booster.rampType = .sCurve
                slider3Value.stringValue = "S Curve"
            }
        }
    }

    private func roundTo(_ value: Double, decimalPlaces: Int) -> Double {
        let decimalValue = pow(10.0, Double(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }

}
