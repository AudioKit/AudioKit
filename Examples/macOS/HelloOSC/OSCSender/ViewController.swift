//
//  ViewController.swift
//  OSCSender
//
//  Created by Shane Dunne on 2019-01-01, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Cocoa
import SwiftOSC

class ViewController: NSViewController, NSWindowDelegate {

    var client = OSCClient(address: "localhost", port: 9_001)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // These two functions (and inheriting from NSWindowDelegate) ensure that
    // app quits when the red close button in the window title bar is clicked.
    override func viewDidAppear() {
        self.view.window?.title = "OSCSender"
        self.view.window?.delegate = self
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    @IBAction func onOsc1SliderChange(_ sender: NSSlider) {
        client.send(OSCMessage(OSCAddressPattern("/osc1/freq"), sender.floatValue))
    }

    @IBAction func onOsc2SliderChange(_ sender: NSSlider) {
        client.send(OSCMessage(OSCAddressPattern("/osc2/freq"), sender.floatValue))
    }

    @IBAction func onPlayStop(_ sender: Any) {
        client.send(OSCMessage(OSCAddressPattern("/play")))
    }
}
