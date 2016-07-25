//
//  AKPolyphonicKeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public class AKPolyphonicKeyboardView: NSView {
    
    public var delegate: AKKeyboardDelegate?
    var keys: [AKKeyView] = []
    
    var onKeys: Set<AKKeyView> = []
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    public init(width: Int, height: Int, lowestKey: Int = 48, totalKeys: Int = 37) {
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
                let newButton = AKKeyView(frame:
                    CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    newButton.backgroundColor = AKColor.blackColor()
                } else {
                    newButton.backgroundColor = AKColor.whiteColor()
                }
                
                newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                newButton.frame.origin.y = CGFloat(1)
                newButton.midiNote = lowestKey + increment
                keys.append(newButton)
                self.addSubview(newButton)
                keyCount += 1
                
            }
            increment += 1
            
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                if onKeys.contains(key) {
                    delegate?.noteOff(key.midiNote)
                    if notesWithSharps[key.midiNote % 12].rangeOfString("#") != nil {
                        key.backgroundColor = AKColor.blackColor()
                    } else {
                        key.backgroundColor = AKColor.whiteColor()
                    }
                    onKeys.remove(key)
                } else {
                    delegate?.noteOn(key.midiNote)
                    key.backgroundColor = AKColor.redColor()
                    onKeys.insert(key)
                }

            }
            
        }
    }

}
