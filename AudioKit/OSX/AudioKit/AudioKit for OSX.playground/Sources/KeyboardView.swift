//
//  KeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//


import Cocoa

public protocol KeyboardDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
}

public class KeyView: NSView {
    public var backgroundColor = NSColor.blackColor()
    public var midiNote = -1
    public var delegate: KeyboardDelegate?

    override public func drawRect(dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFill(self.bounds)
    }
}

public class KeyboardView: NSView {

    var keys: [KeyView] = []
    var delegate: KeyboardDelegate?

    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    override public func drawRect(dirtyRect: NSRect) {
        NSColor.blackColor().setFill()
        NSRectFill(self.bounds)
    }

    public init(width: Int, height: Int,
                delegate: KeyboardDelegate,
                lowestKey: Int = 48,
                totalKeys: Int = 37) {
        self.delegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]

        let keyWidth = width / totalKeys - 1
        let height = Int(frame.height)

        let blackFrame = NSView(frame:
            CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        blackFrame.layer?.backgroundColor = CGColorCreateGenericGray(0.5, 0.5)
        self.addSubview(blackFrame)

        var keyCount = 0
        var increment = 0
        while keyCount < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil ||
                allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                let newButton = KeyView(frame:
                    CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    newButton.backgroundColor = NSColor.blackColor()
                } else {
                    newButton.backgroundColor = NSColor.whiteColor()
                }

                newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                newButton.frame.origin.y = CGFloat(1)

                newButton.midiNote = lowestKey + increment
                newButton.delegate = delegate

                keys.append(newButton)
                self.addSubview(newButton)
                keyCount += 1

            }
            increment += 1

        }
    }

    override public func mouseDown(event: NSEvent) {
        let x = event.locationInWindow.x - self.frame.origin.x
        let y = event.locationInWindow.y - self.frame.origin.y

        for key in keys {
            if key.frame.contains(CGPoint(x: x, y: y)) {
                delegate?.noteOn(key.midiNote)
            }

        }
    }

    override public func mouseDragged(event: NSEvent) {
        let x = event.locationInWindow.x - self.frame.origin.x
        let y = event.locationInWindow.y - self.frame.origin.y

        for key in keys {
            if key.frame.contains(CGPoint(x: x, y: y)) {
                delegate?.noteOn(key.midiNote)
            }

        }
    }

    override public func mouseUp(event: NSEvent) {
        delegate?.noteOff(0)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
