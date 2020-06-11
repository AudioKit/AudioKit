// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
import Cocoa

// If you make changes to this class, either don't commit them, or make sure you don't break the exisiting setup.
class ViewController: NSViewController {
    @IBOutlet var startButton: NSButton!

    @IBOutlet var playerBox: NSBox!

    // Default controls
    @IBOutlet var playButton: NSButton!

    @IBOutlet var gainSlider: NSSlider!
    @IBOutlet var gainValue: NSTextField!
    @IBOutlet var rateSlider: NSSlider!
    @IBOutlet var rateValue: NSTextField!

    @IBOutlet var pitchSlider: NSSlider!
    @IBOutlet var pitchValue: NSTextField!

    @IBOutlet var taperSlider: NSSlider!
    @IBOutlet var taperValue: NSTextField!

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
        view.window?.appearance = NSAppearance(named: .vibrantDark)
        openPanel.appearance = NSAppearance(named: .vibrantDark)

        osc.frequency.value = 220
        osc.amplitude.value = 1
        osc.rampDuration = 0.0
        osc.stop() // it seems to be playing by default now?

        osc >>> mixer
        speechSynthesizer >>> mixer

        AKManager.output = mixer

        openPanel.message = "Open Audio File"
        openPanel.allowedFileTypes = EZAudioFile.supportedAudioFileTypes() as? [String]

        // start engine
        start(startButton)

        if let url = Bundle.main.url(forResource: "PinkNoise", withExtension: "wav") {
            createPlayer(url: url)
        }
    }

    @IBAction func start(_ sender: NSButton) {
        var state = AKManager.engine.isRunning

        do {
            if state {
                try AKManager.stop()
            } else {
                try AKManager.start()
                AKLog("Started engine with format", AKManager.engine.outputNode.outputFormat(forBus: 0))
            }
            state = AKManager.engine.isRunning
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

        do {
            try player?.load(url: url)

        } catch let err as NSError {
            AKLog("🚩", err.description)
            createPlayer(url: url)
        }

        AKLog("Opened", url.path, "duration", player?.duration, "processingFormat", player?.processingFormat)
    }

    private func createPlayer(url: URL) {
        // make a new player so it's not necessary to rebalance format types
        // if the processingFormat changes
        if player != nil {
            player?.detach()
            player = nil
        }
        AKLog("Creating player...", url)
        player = AKDynamicPlayer(url: url)
        player?.completionHandler = handleAudioComplete
        player?.isLooping = loopButton.state == .on
        connectPlayer()
    }

    private func connectPlayer() {
        guard let player = player else { return }

        player >>> mixer

        handleUpdateParam(gainSlider)
        handleUpdateParam(rateSlider)
        handleUpdateParam(pitchSlider)
        handleUpdateParam(fadeInSlider)
        handleUpdateParam(fadeOutSlider)
        handleUpdateParam(taperSlider)
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
            player.gain = AUValue(gain)
        } else if sender == rateSlider {
            player.rate = rateSlider.floatValue
            rateValue.stringValue = String(describing: roundTo(rateSlider.doubleValue, decimalPlaces: 3))

        } else if sender == pitchSlider {
            player.pitch = pitchSlider.floatValue
            pitchValue.stringValue = String(describing: roundTo(pitchSlider.doubleValue, decimalPlaces: 1))

        } else if sender == fadeInSlider {
            player.fade.inTime = fadeInSlider.doubleValue
            fadeInValue.stringValue = String(describing: roundTo(fadeInSlider.doubleValue, decimalPlaces: 3))

        } else if sender == fadeOutSlider {
            player.fade.outTime = fadeInSlider.doubleValue
            fadeOutValue.stringValue = String(describing: roundTo(fadeOutSlider.doubleValue, decimalPlaces: 3))

        } else if sender == taperSlider {
            player.fade.inTaper = sender.floatValue
            player.fade.outTaper = 1 / sender.floatValue
            taperValue?.stringValue = String(describing: roundTo(sender.doubleValue, decimalPlaces: 3))
        }
    }

    private func roundTo(_ value: Double, decimalPlaces: Int) -> Double {
        let decimalValue = pow(10.0, Double(decimalPlaces))
        return round(value * decimalValue) / decimalValue
    }
}
