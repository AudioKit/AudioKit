//
//  KeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import UIKit

public protocol KeyboardDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
}

public class KeyboardView: UIView {
    
    public var delegate: KeyboardDelegate?
    var keys: [UIView] = []
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    public init(width: Int, height: Int, lowestKey: Int = 48, totalKeys: Int = 37) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let allowedNotes = notesWithSharps //["A", "B", "C#", "D", "E", "F#", "G"]
        
        let keyWidth = width / totalKeys - 1
        let height = Int(frame.height)
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: (keyWidth + 1) * totalKeys + 1, height: height))
        blackFrame.backgroundColor = UIColor.black()
        self.addSubview(blackFrame)
        
        var keyCount = 0
        var increment = 0
        while keyCount < totalKeys {
            if  allowedNotes.index(of: notesWithFlats[(lowestKey + increment) % 12]) != nil || allowedNotes.index(of: notesWithSharps[(lowestKey + increment) % 12]) != nil {
                let newButton = UIView(frame:CGRect(x: 0, y: 0, width: keyWidth, height: height - 2))
                if notesWithSharps[(lowestKey + increment) % 12].contains("#") {
                    newButton.backgroundColor = UIColor.black()
                } else {
                    newButton.backgroundColor = UIColor.white()
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
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            for key in keys {
                if key.frame.contains(touch.location(in: self)) {
                    delegate?.noteOn(note: key.tag)
                }
            }
            
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {

            for key in keys {
                if key.frame.contains(touch.location(in: self)) {
                    delegate?.noteOn(note: key.tag)
                }
            }
            
            // determine vertical value
            //setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            for key in keys {
                if key.frame.contains(touch.location(in: self)) {
                    delegate?.noteOff(note: key.tag)
                }
            }
        }
    }
}
