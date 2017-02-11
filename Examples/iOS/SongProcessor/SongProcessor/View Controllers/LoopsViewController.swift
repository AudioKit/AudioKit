//
//  LoopsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class LoopsViewController: UIViewController {

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    fileprivate func playNew(loop: String) {
        songProcessor.audioFile = try? AKAudioFile(readFileName: "\(loop)loop.wav", baseDir: .resources)
        let _ = try? songProcessor.audioFilePlayer?.replace(file: songProcessor.audioFile!)
        songProcessor.audioFilePlayer?.play()
    }

    @IBAction func playMix(_ sender: UIButton) {
        playNew(loop: "mix")
    }

    @IBAction func playDrums(_ sender: UIButton) {
        playNew(loop: "drum")
    }

    @IBAction func playBass(_ sender: UIButton) {
        playNew(loop: "bass")
    }

    @IBAction func playGuitar(_ sender: UIButton) {
        playNew(loop: "guitar")
    }

    @IBAction func playLead(_ sender: UIButton) {
        playNew(loop: "lead")
    }

    @IBAction func stop(_ sender: UIButton) {
        songProcessor.audioFilePlayer?.stop()
    }

}
