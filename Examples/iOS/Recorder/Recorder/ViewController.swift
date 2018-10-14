//
//  AppDelegate.swift
//  Recorder
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!

    let mic = AKMicrophone()

    var state = State.readyToRecord

    @IBOutlet private var plot: AKNodeOutputPlot?
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var mainButton: UIButton!
    @IBOutlet private weak var frequencySlider: AKSlider!
    @IBOutlet private weak var resonanceSlider: AKSlider!
    @IBOutlet private weak var loopButton: UIButton!
    @IBOutlet private weak var moogLadderTitle: UILabel!

    enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()

        // Session settings
        AKSettings.bufferLength = .medium

        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }

        AKSettings.defaultToSpeaker = true

        // Patching
        let monoToStereo = AKStereoFieldLimiter(mic, amount: 1)
        micMixer = AKMixer(monoToStereo)
        micBooster = AKBooster(micMixer)

        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = AKPlayer(audioFile: file)
        }
        player.isLooping = true
        player.completionHandler = playingEnded

        moogLadder = AKMoogLadder(player)

        mainMixer = AKMixer(moogLadder, micBooster)

        AudioKit.output = mainMixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        plot?.node = mic
        setupButtonNames()
        setupUIForRecording()
    }

    // CallBack triggered when playing has ended
    // Must be seipatched on the main queue as completionHandler
    // will be triggered by a background thread
    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying ()
        }
    }

    @IBAction func mainButtonTouched(sender: UIButton) {
        switch state {
        case .readyToRecord :
            infoLabel.text = "Recording"
            mainButton.setTitle("Stop", for: .normal)
            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { AKLog("Errored recording.") }

        case .recording :
            // Microphone monitoring is muted
            micBooster.gain = 0
            tape = recorder.audioFile!
            player.load(audioFile: tape)

            if let _ = player.audioFile?.duration {
                recorder.stop()
                tape.exportAsynchronously(name: "TempTestFile.m4a",
                                          baseDir: .documents,
                                          exportFormat: .m4a) {_, exportError in
                    if let error = exportError {
                        AKLog("Export Failed \(error)")
                    } else {
                        AKLog("Export succeeded")
                    }
                }
                setupUIForPlaying()
            }
        case .readyToPlay :
            player.play()
            infoLabel.text = "Playing..."
            mainButton.setTitle("Stop", for: .normal)
            state = .playing
            plot?.node = player

        case .playing :
            player.stop()
            setupUIForPlaying()
            plot?.node = mic
        }
    }

    struct Constants {
        static let empty = ""
    }

    func setupButtonNames() {
        resetButton.setTitle(Constants.empty, for: UIControl.State.disabled)
        mainButton.setTitle(Constants.empty, for: UIControl.State.disabled)
        loopButton.setTitle(Constants.empty, for: UIControl.State.disabled)
    }

    func setupUIForRecording () {
        state = .readyToRecord
        infoLabel.text = "Ready to record"
        mainButton.setTitle("Record", for: .normal)
        resetButton.isEnabled = false
        resetButton.isHidden = true
        micBooster.gain = 0
        setSliders(active: false)
    }

    func setupUIForPlaying () {
        let recordedDuration = player != nil ? player.audioFile?.duration  : 0
        infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration!)) seconds"
        mainButton.setTitle("Play", for: .normal)
        state = .readyToPlay
        resetButton.isHidden = false
        resetButton.isEnabled = true
        setSliders(active: true)
        moogLadder.cutoffFrequency = frequencySlider.range.upperBound
        frequencySlider.value = moogLadder.cutoffFrequency
        resonanceSlider.value = moogLadder.resonance
    }

    func setSliders(active: Bool) {
        loopButton.isEnabled = active
        moogLadderTitle.isEnabled = active
        frequencySlider.callback = updateFrequency
        frequencySlider.isHidden = !active
        resonanceSlider.callback = updateResonance
        resonanceSlider.isHidden = !active
        frequencySlider.range = 10 ... 20_000
        frequencySlider.taper = 3
        moogLadderTitle.text = active ? "Moog Ladder Filter" : Constants.empty
    }

    @IBAction func loopButtonTouched(sender: UIButton) {

        if player.isLooping {
            player.isLooping = false
            sender.setTitle("Loop is Off", for: .normal)
        } else {
            player.isLooping = true
            sender.setTitle("Loop is On", for: .normal)

        }

    }
    @IBAction func resetButtonTouched(sender: UIButton) {
        player.stop()
        plot?.node = mic
        do {
            try recorder.reset()
        } catch { AKLog("Errored resetting.") }

        //try? player.replaceFile((recorder.audioFile)!)
        setupUIForRecording()
    }

    func updateFrequency(value: Double) {
        moogLadder.cutoffFrequency = value
        frequencySlider.property = "Frequency"
        frequencySlider.format = "%0.0f"
    }

    func updateResonance(value: Double) {
        moogLadder.resonance = value
        resonanceSlider.property = "Resonance"
        resonanceSlider.format = "%0.3f"
    }

}
