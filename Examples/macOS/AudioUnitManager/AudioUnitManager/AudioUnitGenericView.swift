//
//  GenericAudioUnitView.swift
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation
import Cocoa

/// Creates a simple list of parameters linked to sliders
class AudioUnitGenericView: NSView {
    open var name: String = ""
    open var preferredWidth: CGFloat = 360
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
            let rect = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            rect.fill()
        }
    }

    convenience init(audioUnit: AVAudioUnit) {
        self.init()
        wantsLayer = true

        if let cname = audioUnit.auAudioUnit.componentName {
            name = cname
        }

        let nameField = NSTextField()
        nameField.isSelectable = false
        nameField.isBordered = false
        nameField.isEditable = false
        nameField.alignment = .center
        nameField.font = NSFont.boldSystemFont(ofSize: 12)
        nameField.textColor = NSColor.white
        nameField.backgroundColor = NSColor.white.withAlphaComponent(0)
        nameField.stringValue = name
        nameField.frame = NSRect(x: 0, y: 4, width: preferredWidth, height: 20)
        addSubview(nameField)

        guard let tree = audioUnit.auAudioUnit.parameterTree else { return }

        var y = 5
        for param in tree.allParameters {
            y += 24

            let slider = AudioUnitParamSlider(audioUnit: audioUnit, param: param)
            slider.setFrameOrigin(NSPoint(x: 10, y: y))

            addSubview(slider)
            DispatchQueue.main.async {
                slider.updateValue()
            }
        }
        preferredHeight = CGFloat(y + 50)
        frame.size = NSSize(width: preferredWidth, height: preferredHeight)
    }
}
