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
    public let toolbar = AudioUnitToolbarController(nibName: "AudioUnitToolbarController", bundle: Bundle.main)

    private var audioUnit: AVAudioUnit?

    convenience init(audioUnit: AVAudioUnit) {
        self.init(windowNibName: "AudioUnitGenericWindow")
        contentViewController?.view.wantsLayer = true
        self.audioUnit = audioUnit
        toolbar.audioUnit = audioUnit
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.addTitlebarAccessoryViewController(toolbar)
    }
}
