// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitUI
import Cocoa

class ViewController: NSViewController {
    @IBOutlet var stopButton: AKButton!
    @IBOutlet var playButton: AKButton!
    @IBOutlet var recordButton: AKButton!
    @IBOutlet var inputPlot: AKNodeOutputPlot!

    public var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
    lazy var mic = AKMicrophone()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2) else { return }
        AKSettings.audioFormat = audioFormat

        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.black

        stopButton.title = "Stop"
        stopButton.callback = { _ in
            DispatchQueue.main.async {
                self.stop()
            }
        }

        playButton.title = "Play"
        playButton.callback = { _ in
            self.play()
        }

        recordButton.title = "Record"
        recordButton.callback = { _ in
            self.record()
        }

        AKLog(AKSettings.audioFormat, "inputNode:", AKManager.engine.inputNode.outputFormat(forBus: 0).sampleRate)

        // Patching
        inputPlot.node = mic
        inputPlot.backgroundColor = NSColor.black

        AKLog(mic?.outputNode.inputFormat(forBus: 0))

        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)

        player = AKPlayer()
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
        AKNodeRecorder.removeTempFiles()

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

        do {
            try player.load(url: audioFile.url)

        } catch let err as NSError {
            AKLog(err.localizedDescription)
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["m4a"]
        savePanel.allowsOtherFileTypes = false
        savePanel.message = "Save your recorded output"

        guard savePanel.runModal() == .OK else { return }
        guard let outputURL = savePanel.url else { return }

        var options = AKConverter.Options()
        options.bitDepth = 16
        options.sampleRate = AKSettings.sampleRate
        options.format = "m4a"

        let converter = AKConverter(inputURL: audioFile.url, outputURL: outputURL, options: options)

        converter.start { error in
            if let error = error {
                AKLog("Error saving file", error.localizedDescription)
            }
        }
    }

    @IBAction func terminate(_ sender: Any) {
        AKNodeRecorder.removeTempFiles()
        exit(0)
    }
}
