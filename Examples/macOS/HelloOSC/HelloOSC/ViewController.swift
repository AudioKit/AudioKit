//
//  ViewController.swift
//  HelloOSC
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import Cocoa
import SwiftOSC

class ViewController: NSViewController, NSWindowDelegate, OSCServerDelegate {

    @IBOutlet private var plot: AKNodeOutputPlot!

    var oscillator1 = AKOscillator()
    var oscillator2 = AKOscillator()
    var mixer = AKMixer()

    var server = OSCServer(address: "", port: 9_001)

    override func viewDidLoad() {
        super.viewDidLoad()

        oscillator1.frequency = 440
        oscillator2.frequency = 660

        mixer = AKMixer(oscillator1, oscillator2)
        plot.node = mixer

        // Cut the volume in half since we have two oscillators
        mixer.volume = 0.5
        AudioKit.output = mixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        server.start()
        server.delegate = self
    }

    // These two functions (and inheriting from NSWindowDelegate) ensure that
    // app quits when the red close button in the window title bar is clicked.
    override func viewDidAppear() {
        self.view.window?.title = "HelloOSC"
        self.view.window?.delegate = self
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    func toggleSound() {
        if oscillator1.isPlaying {
            oscillator1.stop()
            oscillator2.stop()
        } else {
            oscillator1.start()
            oscillator2.start()
        }
    }

    func didReceive(_ message: OSCMessage) {
        if message.address.matches(path: OSCAddress("/osc1/freq")) {
            if let arg = message.arguments[0] as? Float {
                oscillator1.frequency = Double(arg)
            }
        } else if message.address.matches(path: OSCAddress("/osc2/freq")) {
            if let arg = message.arguments[0] as? Float {
                oscillator2.frequency = Double(arg)
            }
        } else if message.address.matches(path: OSCAddress("/play")) {
            toggleSound()
        } else {
            print(message)
        }
    }

}
