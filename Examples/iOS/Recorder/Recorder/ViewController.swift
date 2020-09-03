// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import UIKit

class ViewController: UIViewController {
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer!
    var tape: AVAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!

    let engine = AKEngine()
    // this is lazy here so that the sample rate can be set before it's created by reference
    lazy var mic = AKMicrophone(engine: engine.avEngine)

    var state = State.readyToRecord

    @IBOutlet private var plot: AKNodeOutputPlot?
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var resetButton: UIButton!
    @IBOutlet private var mainButton: UIButton!
    @IBOutlet private var frequencySlider: AKSlider!
    @IBOutlet private var resonanceSlider: AKSlider!
    @IBOutlet private var loopButton: UIButton!
    @IBOutlet private var moogLadderTitle: UILabel!

    enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Session settings
        AKSettings.bufferLength = .medium

        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }

        // Kludge to align sample rates of the graph with the current input sample rate
        AKSettings.sampleRate = engine.avEngine.inputNode.inputFormat(forBus: 0).sampleRate

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

        engine.output = mainMixer
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        plot?.node = mic
        setupButtonNames()
        setupUIForRecording()
    }

    // CallBack triggered when playing has ended
    // Must be seipatched on the main queue as completionHandler
    // will be triggered by a background thread
    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying()
        }
    }

    @IBAction func mainButtonTouched(sender: UIButton) {
        switch state {
        case .readyToRecord:
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

        case .recording:
            // Microphone monitoring is muted
            micBooster.gain = 0
            recorder.stop()
            tape = recorder.audioFile!
            try? player.load(audioFile: tape)

            do {
                try player.load(audioFile: tape)
                setupUIForPlaying()
            } catch let err as NSError {
                AKLog(err)
                // Assuming formats match, this should load
                return
            }

        // NOTE: there could be another export function in here that creates an AKConverter to export
        // to the destination of choice if desired. See the macOS Recorder example if interested
        case .readyToPlay:
            player.play()
            infoLabel.text = "Playing..."
            mainButton.setTitle("Stop", for: .normal)
            state = .playing
            plot?.node = player

        case .playing:
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

    func setupUIForRecording() {
        state = .readyToRecord
        infoLabel.text = "Ready to record"
        mainButton.setTitle("Record", for: .normal)
        resetButton.isEnabled = false
        resetButton.isHidden = true
        micBooster.gain = 0
        setSliders(active: false)
    }

    func setupUIForPlaying() {
        let recordedDuration = player != nil ? player.audioFile?.duration : 0
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

        // try? player.replaceFile((recorder.audioFile)!)
        setupUIForRecording()
    }

    func updateFrequency(value: AUValue) {
        moogLadder.cutoffFrequency = value
        frequencySlider.property = "Frequency"
        frequencySlider.format = "%0.0f"
    }

    func updateResonance(value: AUValue) {
        moogLadder.resonance = value
        resonanceSlider.property = "Resonance"
        resonanceSlider.format = "%0.3f"
    }
}
