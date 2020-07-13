// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
import Cocoa

class ViewController: NSViewController {
    @IBOutlet var stopButton: AKButton!
    @IBOutlet var playButton: AKButton!
    @IBOutlet var recordButton: AKButton!

    public var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer!
    var tape: AVAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
    @IBOutlet var inputPlot: AKNodeOutputPlot!

    let mic = AKMicrophone()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer?.backgroundColor = CGColor.black

        stopButton.title = "Stop"
        stopButton.color = NSColor.blue
        stopButton.callback = { _ in
            self.stop()
        }

        playButton.title = "Play"
        playButton.color = NSColor.green
        playButton.callback = { _ in
            self.play()
        }

        recordButton.title = "Record"
        recordButton.color = NSColor.red
        recordButton.callback = { _ in
            self.record()
        }

        // Patching
        inputPlot.node = mic
        inputPlot.backgroundColor = NSColor.black
        micMixer = AKMixer(mic)
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

        AKManager.output = mainMixer
        do {
            try AKManager.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    func playingEnded() {
        DispatchQueue.main.async {
            AKLog("Playing Ended")
        }
        inputPlot.node = mic
    }

    func record() {
        inputPlot.node = mic
        do {
            try recorder.record()
        } catch { AKLog("Errored recording.") }
    }

    func play() {
        player.play()
        inputPlot.node = player
    }

    func stop() {
        player.stop()
        inputPlot.node = mic
        micBooster.gain = 0

        recorder.stop()

        guard let audioFile = recorder.audioFile else { return }
        tape = audioFile

        do {
            try player.load(audioFile: audioFile)

        } catch let err as NSError {
            AKLog(err.localizedDescription)
            return
        }

        guard let outputURL = documentsDirectory?.appendingPathComponent("TempTestFile.m4a") else { return }

        var options = AKConverter.Options()
        options.bitDepth = 16
        options.sampleRate = AKSettings.sampleRate
        options.format = "m4a"

        let converter = AKConverter()
        converter.options = options
        converter.inputURL = audioFile.url
        converter.outputURL = outputURL

        converter.start { error in
            if let error = error {
                AKLog("Error saving file", error.localizedDescription)
            }
        }
    }
}
