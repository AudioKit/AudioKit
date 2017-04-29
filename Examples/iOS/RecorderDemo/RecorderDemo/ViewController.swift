import AudioKit
import UIKit

class ViewController: UIViewController {

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKAudioPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!

    let mic = AKMicrophone()

    var state = State.readyToRecord

    @IBOutlet private var inputPlot: AKNodeOutputPlot!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var mainButton: UIButton!
    @IBOutlet private weak var frequencySlider: AKPropertySlider!
    @IBOutlet private weak var resonanceSlider: AKPropertySlider!
    @IBOutlet private weak var loopButton: UIButton!
    @IBOutlet private weak var moogLadderTitle: UILabel!

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
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }

        AKSettings.defaultToSpeaker = true

        // Patching
        inputPlot.node = mic
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }
        player.looping = true
        player.completionHandler = playingEnded

        moogLadder = AKMoogLadder(player)

        mainMixer = AKMixer(moogLadder, micBooster)

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
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { print("Errored recording.") }

        case .recording :
            // Microphone monitoring is muted
            micBooster.gain = 0
            do {
                try player.reloadFile()
            } catch { print("Errored reloading.") }

            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                player.audioFile.exportAsynchronously(name: "TempTestFile.m4a",
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) {_, exportError in
                    if let error = exportError {
                        print("Export Failed \(error)")
                    } else {
                        print("Export succeeded")
                    }
                }
                setupUIForPlaying ()
            }
        case .readyToPlay :
            player.play()
            infoLabel.text = "Playing..."
            mainButton.setTitle("Stop", for: .normal)
            state = .playing
        case .playing :
            player.stop()
            setupUIForPlaying()
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
        micBooster.gain = 0
        setSliders(active: false)
    }

    func setupUIForPlaying () {
        let recordedDuration = player != nil ? player.audioFile.duration  : 0
        infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
        mainButton.setTitle("Play", for: .normal)
        state = .readyToPlay
        resetButton.isHidden = false
        resetButton.isEnabled = true
        setSliders(active: true)
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
        frequencySlider.maximum = 2_000
        moogLadderTitle.text = active ? "Moog Ladder Filter" : Constants.empty
    }

    @IBAction func loopButtonTouched(sender: UIButton) {

        if player.looping {
            player.looping = false
            sender.setTitle("Loop is Off", for: .normal)
        } else {
            player.looping = true
            sender.setTitle("Loop is On", for: .normal)

        }

    }
    @IBAction func resetButtonTouched(sender: UIButton) {
        player.stop()
        do {
            try recorder.reset()
        } catch { print("Errored resetting.") }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
