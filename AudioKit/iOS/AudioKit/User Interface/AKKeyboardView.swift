//
//  AKKeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import UIKit

public protocol AKKeyboardDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
}

public class AKKeyboardView: UIView {

    public var delegate: AKKeyboardDelegate?
    var keys: [UIView] = []

    var onKeys: Set<UIView> = []

    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    public init(width: Int, height: Int, lowestKey: Int = 48, totalKeys: Int = 37) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]

        let keyWidth = width / totalKeys - 1
        let height = Int(frame.height)

        let blackFrame = UIView(frame:
            CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        blackFrame.backgroundColor = UIColor.blackColor()
        self.addSubview(blackFrame)

        var keyCount = 0
        var increment = 0
        while keyCount < totalKeys {
            if  allowedNotes.indexOf(notesWithFlats[(lowestKey + increment) % 12]) != nil ||
                allowedNotes.indexOf(notesWithSharps[(lowestKey + increment) % 12]) != nil {
                let newButton = UIView(frame:
                    CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                if notesWithSharps[(lowestKey + increment) % 12].rangeOfString("#") != nil {
                    newButton.backgroundColor = UIColor.blackColor()
                } else {
                    newButton.backgroundColor = UIColor.whiteColor()
                }

                newButton.setNeedsDisplay()

                newButton.frame.origin.x = CGFloat(keyCount * (keyWidth + 1)) + 1
                newButton.frame.origin.y = CGFloat(1)
                newButton.tag = lowestKey + increment
                keys.append(newButton)
                self.addSubview(newButton)
                keyCount += 1

            }
            increment += 1

        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {

            for key in keys where !onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self)) {
                    delegate?.noteOn(key.tag)
                    unhighlightKeys()
                    key.backgroundColor = UIColor.redColor()
                    onKeys.insert(key)
                }
            }

        }
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {

            for key in keys where !onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self)) {
                    delegate?.noteOn(key.tag)
                    unhighlightKeys()
                    key.backgroundColor = UIColor.redColor()
                    onKeys.insert(key)
                }
            }

            // determine vertical value
            //setPercentagesWithTouchPoint(touchPoint)
        }
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            for key in keys where onKeys.contains(key) {
                if CGRectContainsPoint(key.frame, touch.locationInView(self)) {
                    delegate?.noteOff(key.tag)
                    unhighlightKeys()
                }
            }
        }
    }

    func unhighlightKeys() {
        for key in onKeys {
            if notesWithSharps[key.tag % 12].rangeOfString("#") != nil {
                key.backgroundColor = UIColor.blackColor()
            } else {
                key.backgroundColor = UIColor.whiteColor()
            }
        }
        onKeys.removeAll()
    }
}
