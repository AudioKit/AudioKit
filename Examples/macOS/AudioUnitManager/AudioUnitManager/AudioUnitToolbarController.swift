//
//  AudioUnitToolbarController.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 8/5/18.
//  Copyright © 2018 Ryan Francesconi. All rights reserved.
//

import AudioKit
import AVFoundation
import Cocoa

class AudioUnitToolbarController: NSTitlebarAccessoryViewController {
    @IBOutlet var bypassButton: NSButton!

    public var audioUnit: AVAudioUnit?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func handleBypass(_ sender: NSButton) {
        guard let audioUnit = audioUnit else { return }

        let buttonState = bypassButton.state == .on
        AKLog("bypass: \(buttonState) audioUnit: \(audioUnit)")

        audioUnit.auAudioUnit.shouldBypassEffect = buttonState
    }
}
