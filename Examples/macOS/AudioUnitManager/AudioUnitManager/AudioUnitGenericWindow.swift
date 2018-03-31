//
//  AudioUnitWindow.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AVFoundation
import Cocoa

class AudioUnitGenericWindow: NSWindowController {
    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var toolbar: AudioUnitToolbar!

    private var audioUnit: AVAudioUnit?

    convenience init(audioUnit: AVAudioUnit) {
        self.init(windowNibName: NSNib.Name(rawValue: "AudioUnitGenericWindow"))
        contentViewController?.view.wantsLayer = true
        self.audioUnit = audioUnit
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        toolbar?.audioUnit = audioUnit
    }
}
