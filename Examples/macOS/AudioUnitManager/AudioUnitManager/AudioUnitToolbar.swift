//
//  AudioUnitToolbar.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AVFoundation
import Cocoa

class AudioUnitToolbar: NSView {
    @IBInspectable var backgroundColor: NSColor?

    var audioUnit: AVAudioUnit?

    var bypassButton = NSButton()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        initialize()
    }

    private func initialize() {
        bypassButton = NSButton()
        bypassButton.frame = NSRect(x: 2, y: 2, width: 60, height: 16)
        bypassButton.controlSize = .mini
        bypassButton.bezelStyle = .rounded
        bypassButton.font = NSFont.systemFont(ofSize: 9)
        bypassButton.setButtonType(.pushOnPushOff)
        bypassButton.action = #selector(handleBypass)
        bypassButton.target = self
        bypassButton.title = "Bypass"
        addSubview(bypassButton)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if let bgColor = backgroundColor {
            bgColor.setFill()
            let rect = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            rect.fill()
        }
    }

    @objc func handleBypass() {
        Swift.print("bypass: \(bypassButton.state)")
        audioUnit?.auAudioUnit.shouldBypassEffect = bypassButton.state == .on
    }

}
