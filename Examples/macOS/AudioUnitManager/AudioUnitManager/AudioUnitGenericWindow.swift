// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Cocoa

class AudioUnitGenericWindow: NSWindowController {
    @IBOutlet var scrollView: NSScrollView!
    public let toolbar = AudioUnitToolbarController(nibName: "AudioUnitToolbarController", bundle: Bundle.main)

    internal var audioUnit: AVAudioUnit?

    convenience init(audioUnit: AVAudioUnit) {
        self.init(windowNibName: "AudioUnitGenericWindow")
        // contentViewController?.view.wantsLayer = true
        self.audioUnit = audioUnit
        toolbar.audioUnit = audioUnit
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.addTitlebarAccessoryViewController(toolbar)
        window?.appearance = AudioUnitManager.appearance
    }
}
