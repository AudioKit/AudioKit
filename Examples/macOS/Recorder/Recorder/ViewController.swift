//
//  ViewController.swift
//  Recorder
//
//  Created by Aurelius Prochazka on 2/4/17.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Cocoa
import AudioKit
import AudioKitUI

class ViewController: NSViewController {

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKAudioPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
//    @IBOutlet weak var inputPlot: AKNodeOutputPlot!

    let mic = AKMicrophone()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Patching
//        inputPlot.node = mic
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

    }

    func playingEnded() {
        DispatchQueue.main.async {
            Swift.print("Playing Ended")
        }
    }

    @IBAction func record(_ sender: Any) {
        do {
            try recorder.record()
        } catch { print("Errored recording.") }
    }
    @IBAction func play(_ sender: Any) {
        player.play()
    }
    @IBAction func stop(_ sender: Any) {
        player.stop()
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
        }
    }
    @IBAction func reset(_ sender: Any) {
        player.stop()
        do {
            try recorder.reset()
        } catch { print("Errored resetting.") }
    }

}
