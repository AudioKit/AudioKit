//
//  AudioUnitWindow.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 10/8/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AVFoundation
import Cocoa

class AudioUnitGenericWindow: NSWindowController {
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var toolbar: AudioUnitToolbar!

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
