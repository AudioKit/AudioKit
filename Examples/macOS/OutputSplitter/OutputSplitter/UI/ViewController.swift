//
//  ViewController.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Cocoa
import AudioKitUI

class ViewController: NSViewController {
    var playButton: AKButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = AKButton()
        playButton.title = "Play"
        playButton.frame = view.bounds
        view.addSubview(playButton)
        
        playButton.callback = { _ in
            if Application.engine.player.isPlaying {
                Application.engine.player.stop()
                self.playButton.title = "Play"
            } else {
                Application.engine.player.setPosition(0)
                Application.engine.player.play()
                self.playButton.title = "Stop"
            }
        }
    }
}




