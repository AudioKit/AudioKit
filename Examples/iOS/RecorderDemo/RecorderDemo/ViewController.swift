//
//  ViewController.swift
//  RecorderDemo
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {


    var recorder: AKNodeRecorder?
    var player: AKAudioPlayer?
    var tape: AKAudioFile?
    var micBooster: AKBooster?
    var moogLadder: AKMoogLadder?

    var state = State.readyToRecord

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var resonLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!

    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var freqSlider: UISlider!
    @IBOutlet weak var moogLadderTitle: UILabel!
    @IBOutlet weak var resonSlider: UISlider!

    enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupButtonNames()

        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()
        
        // Session settings
        AKSettings.bufferLength = .medium

        do {
            try AKSettings.setSessionCategory(.PlayAndRecord, withOptions: .defaultToSpeaker)
        } catch { print("Errored setting category.") }

        // Patching
        let mic = AKMicrophone()
        let micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        // Will set the level of microphone monitoring
        micBooster!.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        tape = recorder?.audioFile
        player = tape?.player
        player?.looping = true
        player?.completionHandler = playingEnded

        moogLadder = AKMoogLadder(player!)

        let mainMixer = AKMixer(moogLadder!, micBooster!)

        AudioKit.output = mainMixer
        AudioKit.start()

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
                micBooster!.gain = 1
            }
            do {
                try recorder?.record()
            } catch { print("Errored recording.") }

        case .recording :
            // Microphone monitoring is muted
            micBooster!.gain = 0
            do {
                try player?.reloadFile()
            } catch { print("Errored reloading.") }

            let recordedDuration = player != nil ? player?.audioFile.duration  : 0
            if recordedDuration! > 0.0 {
                recorder?.stop()
                setupUIForPlaying ()
            }
        case .readyToPlay :
            player!.play()
            infoLabel.text = "Playing..."
            mainButton.setTitle("Stop", for: .normal)
            state = .playing
        case .playing :
            player?.stop()
            setupUIForPlaying ()
        }
    }
    
    struct Constants {
        static let empty = ""
    }
    
    func setupButtonNames() {
        resetButton.setTitle(Constants.empty, for: UIControlState.disabled)
        mainButton.setTitle(Constants.empty, for: UIControlState.disabled)
        loopButton.setTitle(Constants.empty, for: UIControlState.disabled)
    }

    func setupUIForRecording () {
        state = .readyToRecord
        infoLabel.text = "Ready to record"
        mainButton.setTitle("Record", for: .normal)
        resetButton.isEnabled = false
        resetButton.isHidden = true
        micBooster?.gain = 0
        setSliders(active: false)
    }

    func setupUIForPlaying () {
        let recordedDuration =  player != nil ? player?.audioFile.duration  : 0
        infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration!)) seconds"
        mainButton.setTitle("Play", for: .normal)
        state = .readyToPlay
        resetButton.isHidden = false
        resetButton.isEnabled = true
        setSliders(active: true)
    }

    func setSliders(active: Bool) {
        loopButton.isEnabled = active
        moogLadderTitle.isEnabled = active
        freqSlider.isEnabled = active
        freqSlider.isHidden = !active
        resonSlider.isEnabled = active
        resonSlider.isHidden = !active
        freqLabel.isEnabled = active
        resonLabel.isEnabled = active
        freqLabel.text = active ? "Cutoff Frequency" : Constants.empty
        resonLabel.text = active ? "Resonance" : Constants.empty
        moogLadderTitle.text = active ? "Moog Ladder Filter" : Constants.empty
    }

    @IBAction func loopButtonTouched(sender: UIButton) {

        if player!.looping {
            player!.looping = false
            sender.setTitle("Loop is Off", for: .normal)
        } else {
            player!.looping = true
            sender.setTitle("Loop is On", for: .normal)

        }

    }
    @IBAction func resetButtonTouched(sender: UIButton) {
        player!.stop()
        do {
            try recorder?.reset()
        } catch { print("Errored resetting.") }

        //try? player?.replaceFile((recorder?.audioFile)!)
        setupUIForRecording()
    }

    @IBAction func resonSliderChanged(sender: UISlider) {
        moogLadder?.resonance = Double(sender.value)
        resonLabel!.text = "Resonance: \(String(format: "%0.3f", moogLadder!.resonance))"
    }

    @IBAction func freqSliderChanged(sender: UISlider) {
        moogLadder?.cutoffFrequency = Double(sender.value)
        freqLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", moogLadder!.cutoffFrequency))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
