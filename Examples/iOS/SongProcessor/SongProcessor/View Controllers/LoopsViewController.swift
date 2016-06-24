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
    
    private func playNew(loop loop: String) {
        songProcessor.audioFile = try? AKAudioFile(readFileName: "\(loop)loop.wav", baseDir: .Resources)
        let _ = try? songProcessor.audioFilePlayer?.replaceFile(songProcessor.audioFile!)
        songProcessor.audioFilePlayer?.play()
    }
    
    @IBAction func playMix(sender: UIButton) {
        playNew(loop: "mix")
    }

    @IBAction func playDrums(sender: UIButton) {
        playNew(loop: "drum")
    }

    @IBAction func playBass(sender: UIButton) {
        playNew(loop: "bass")
    }
    
    @IBAction func playGuitar(sender: UIButton) {
        playNew(loop: "guitar")
    }
    
    @IBAction func playLead(sender: UIButton) {
        playNew(loop: "lead")
    }

    @IBAction func stop(sender: UIButton) {
        songProcessor.audioFilePlayer?.stop()
    }
    
}
