//
//  ViewController.swift
//  Recorder
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Cocoa
import AudioKit
import AudioKitUI

class ViewController: NSViewController {

    @IBOutlet weak var stopButton: AKButton!
    @IBOutlet weak var playButton: AKButton!
    @IBOutlet weak var recordButton: AKButton!

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
    @IBOutlet weak var inputPlot: AKNodeOutputPlot!

    let mic = AKMicrophone()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer?.backgroundColor = CGColor.black

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

        AudioKit.output = mainMixer
        do {
            try AudioKit.start()
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
        }
    }

}
