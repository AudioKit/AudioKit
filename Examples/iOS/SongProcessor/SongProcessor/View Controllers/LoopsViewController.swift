//
//  LoopsViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

class LoopsViewController: UIViewController {

    let songProcessor = SongProcessor.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(barButton:)))

    }

    fileprivate func playNew(loop: String) {
        if loop == "mix" {
            songProcessor.playersDo { $0.volume = 1 }
        } else {
            guard let player = songProcessor.players[loop] else { return }
            songProcessor.playersDo { $0.volume = $0 == player ? 1 : 0 }
        }
        if !songProcessor.loopsPlaying {
            songProcessor.rewindLoops()
        }
        songProcessor.loopsPlaying = true
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
        songProcessor.iTunesFilePlayer?.stop()
        songProcessor.loopsPlaying = false
    }
    @objc func share(barButton: UIBarButtonItem) {
        renderAndShare { docController in
            guard let canOpen = docController?.presentOpenInMenu(from: barButton, animated: true) else { return }
            if !canOpen {
                self.present(self.alertForShareFail(), animated: true, completion: nil)
            }
        }
    }
}
