//
//  GenericAudioUnitView.swift
//
//  Created by Ryan Francesconi on 6/27/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation

/// Creates a simple list of parameters linked to sliders
class AudioUnitGenericView: NSView {

    open var preferredHeight: CGFloat = 400

    override var isFlipped: Bool {
        return true
    }

    open var opaqueBackground: Bool = true

    open var backgroundColor: NSColor = NSColor.darkGray {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if opaqueBackground {
            backgroundColor.setFill()

            let rect = NSMakeRect(0, 0, bounds.width, bounds.height)
            let rectanglePath = NSBezierPath(roundedRect: rect, xRadius: 5, yRadius: 5)
            rectanglePath.fill()
        }
    }

    convenience init(au: AVAudioUnit) {
        self.init()

        frame.size = NSSize(width: 380, height: 400)

        let nameField = NSTextField()
        nameField.isSelectable = false
        nameField.isBordered = false
        nameField.isEditable = false
        nameField.alignment = .center
        nameField.font = NSFont.boldSystemFont(ofSize: 12)
        nameField.textColor = NSColor.white
        nameField.backgroundColor = NSColor.white.withAlphaComponent(0)
        nameField.stringValue = "\(au.manufacturerName): \(au.name)"
        nameField.frame = NSRect(x: 0, y: 4, width: 400, height: 20)
        addSubview(nameField)

        guard let tree = au.auAudioUnit.parameterTree else { return }

        var y = 5
        for param in tree.allParameters {
            y += 24

            let slider = AudioUnitParamSlider(audioUnit: au, param: param )
            slider.setFrameOrigin(NSPoint(x: 10, y: y))

            addSubview(slider)
            DispatchQueue.main.async {
                slider.updateValue()
            }
        }
        preferredHeight = CGFloat(y + 50)
    }

    func handleChange(_ sender: NSSlider) {
        //Swift.print(sender.doubleValue)
    }

}
