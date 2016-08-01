//
//  KeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//
//  31 July 2016
//  Adapted by Jop van der Werff to resemble a bit more a real-world keyboard
//  This KeyboardView also will begin with a white key and end with a white key
//  according real-world keyboards, but also to function well for the code implemented

import UIKit

let colorKeyPressed = UIColor.orangeColor()
let colorBlackKeyPressed = UIColor.redColor()

var colorBlackKeyIsPressed = colorKeyPressed  // will be UIColor.redColor() when in polyphonic mode

protocol KeyDelegate {
    func keyPress(key: KeyView)
    func keyRelease(key: KeyView)
    func lastKeyRelease()
}

class KeyView : UIView {
    var delegate: KeyDelegate?
    
    var noteName = ""   // Note-name: C, C#, D, D# - at this moment not really used
    var black = false
    var pressed = 0     // key-is-pressed-status:
    //   0 - not pressed
    //   1 - pressed
    //  -1 - pressed, but in polyphonic mode
    
    func pressKey() {
        switch pressed {
        case +1: break
        case -1: releaseKey()  // in polyphonic mode so release key
        default: // ==0 not pressed -> change but Delegate will decide to +1  or -1
            backgroundColor = black ? colorBlackKeyIsPressed : colorKeyPressed
            delegate?.keyPress(self)  // this will also set pressed <> 0, dependant of polyphonic mode
        }
    }
    
    func releaseKey() {
        if pressed != 0 {
            pressed = 0
            backgroundColor = black ? UIColor.blackColor() : UIColor.whiteColor()
            delegate?.keyRelease(self)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pressKey()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        superview?.touchesMoved(touches, withEvent: event) // only here it needs help from "the master"
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch pressed {
        case +1: releaseKey()  // pressed NOT in polyphonic mode so release key
        case -1: break         // in polyphonic mode so do nothing
        default: delegate?.lastKeyRelease()  // delegate acts according polyphonic mode
        }
    }
}

public protocol AKKeyboardDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
}

public class AKKeyboardView: UIView, KeyDelegate {
    public var polyphonicMode = false {
        didSet {
            if polyphonicMode {
                colorBlackKeyIsPressed = colorBlackKeyPressed
                keysFrame!.backgroundColor = UIColor.blueColor()
            } else {
                colorBlackKeyIsPressed = colorKeyPressed
                keysFrame!.backgroundColor = UIColor.greenColor()
                for key in keys where key.pressed != 0 {
                    key.releaseKey()
                }
            }
            //setNeedsDisplay()  // maybe necessary
        }
    }
    
    public var delegate: AKKeyboardDelegate?
    public var totalKeysCorrected: Int = 37
    
    var keys: [KeyView] = []
    
    var lastKeyPressed: KeyView?
    
    let notesWithFlats  = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var keysFrame: UIView?
    
    public init(width: Int, height: Int,
                lowestKey: Int = 48, totalKeys: Int = 37,
                polyphonic: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        //let allowedNotes = notesWithSharps     // ["A", "B", "C#", "D", "E", "F#", "G"]
        
        var increment = 0    // start value for main loop - see below
        if notesWithSharps[lowestKey % 12].rangeOfString("#") != nil {
            increment = -1   // never start with a black key => add one (white) key at leftside
        }
        var extraKey = 0
        if notesWithSharps[(lowestKey + totalKeys - 1) % 12].rangeOfString("#") != nil {
            extraKey = 1   // never end with a black key => add one key at rightside
        }
        totalKeysCorrected = totalKeys - increment + extraKey
        
        var kw = CGFloat(width - 1) / CGFloat(totalKeysCorrected)
        kw = RoundSimple(kw, decimalen: 0)
        let keyWidth = kw - 1
        
        var countWhiteKeys = (totalKeysCorrected / 12) * 7  // number of octaves * 7 white keys
        var k = (lowestKey + increment) % 12; let kEnd = k + totalKeysCorrected % 12
        while k < kEnd {
            if notesWithSharps[k % 12].rangeOfString("#") == nil {
                countWhiteKeys += 1
            }
            k += 1
        }
        
        var whiteKeyWidth = CGFloat(width - 1) / CGFloat(countWhiteKeys) - 1
        whiteKeyWidth = CGFloat(Int(whiteKeyWidth))
        
        let height = Int(frame.height)
        let blackHeight = 3 * height / 5  // relative size of blackkeys on a real keyboard
        // not quite true, but this looks better
        //let widthFrame = kw * CGFloat(totalKeysCorrected) + 1
        let widthFrame = (whiteKeyWidth + 1) * CGFloat(countWhiteKeys) + 1
        
        let blackFrame = UIView(frame: CGRect(x: 0, y: 0, width: widthFrame, height: CGFloat(height)))
        keysFrame = blackFrame     // create pointer to this one as for changing later bg-color
        blackFrame.backgroundColor = UIColor.greenColor()    // black => 'disco green' ;)
        self.addSubview(blackFrame)
        
        polyphonicMode = polyphonic   // init. here and NOT before keysFrame got valid pointervalue!
        
        // calculate once and store for an octave the relative xPositions
        var keysXPos: [CGFloat] = []
        var xNextWhiteKey = CGFloat(1); var iw = 1
        for i in 0...11 { // walk along the 12 keys in an octave
            if notesWithSharps[i].rangeOfString("#") != nil { // it's a black key
                var xBlackKey = xNextWhiteKey
                switch i {  // create subtle position nuances as with real keyboard
                case 1: xBlackKey -= kw * 2/3
                case 3: xBlackKey -= kw * 1/3
                case 6: xBlackKey -= kw * 3/4
                case 8: xBlackKey -= kw * 1/2
                case 10: xBlackKey -= kw * 1/4
                default: xBlackKey = -2 * kw  // out of view
                }
                xBlackKey = RoundSimple(xBlackKey, decimalen: 0)
                keysXPos.append(xBlackKey)
            } else {
                keysXPos.append(xNextWhiteKey)
                xNextWhiteKey = 1 + CGFloat(iw) * (whiteKeyWidth + 1)
                iw += 1       // count the white keys
            }
        }
        let octaveWidth = xNextWhiteKey - 1
        
        var offsetOctave =  -(keysXPos[(lowestKey + increment) % 12] - 1) // - x-offset 1e key
        if offsetOctave == 0 {
            offsetOctave -= octaveWidth
        }
        
        var keyCount = increment
        var holdIndexBlKey = -1
        while keyCount < totalKeys + extraKey {
            let keyInOctave = (lowestKey + increment) % 12
            if keyInOctave == 0 {
                offsetOctave += octaveWidth
            }
            
            let blackKey = notesWithSharps[keyInOctave].rangeOfString("#") != nil
            let (keyHeight, kWidth) = blackKey ? (blackHeight, keyWidth) : (height, whiteKeyWidth)
            
            let newButton = KeyView(frame:CGRect(x: 0, y: 0, width: Int(kWidth), height: keyHeight - 2))
            newButton.tag = lowestKey + increment
            newButton.frame.origin.x = offsetOctave + keysXPos[keyInOctave]
            newButton.frame.origin.y = CGFloat(1)
            
            newButton.noteName = notesWithSharps[keyInOctave]
            
            let showKey = { (button: KeyView) -> Void in
                button.setNeedsDisplay()
                self.addSubview(button)
                if button.black {
                    self.bringSubviewToFront(button)
                }
                button.delegate = self
            }
            
            if blackKey {
                newButton.backgroundColor = UIColor.blackColor()
                newButton.black = true
                holdIndexBlKey = keys.count - 1
                keys.insert(newButton, atIndex: holdIndexBlKey)
            } else {
                newButton.backgroundColor = UIColor.whiteColor()
                keys.append(newButton)
                showKey(newButton)
                if holdIndexBlKey >= 0 { // see if 'bypassed' blackKey has to be outputted
                    showKey(keys[holdIndexBlKey]) // ouput now, so it will cover surrounding white keys
                    holdIndexBlKey = -1  // reset
                }
            }
            keyCount += 1
            increment += 1  // double counting - not really usefull now
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //    public override func removeFromSuperview() {
    //        self.removeFromSuperview()
    //    }
    
    public func GetNoteName(note : Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }
    
    // *********************************************************
    // MARK: - Handle Move Touches
    // *********************************************************
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if polyphonicMode { return } // no response for 'drawing cursor' in polyphonic mode
        
        var keyToReward: KeyView?
        
        for touch in touches {
            for key in keys {
                if CGRectContainsPoint(key.frame, touch.locationInView(self)) {
                    if key.pressed != 0 { // is already in pressed mode
                        return
                    }
                    lastKeyRelease()
                    if key.black {  // handle black keys (covering the white keys) with priority
                        key.pressKey()
                        return      // don't check further as covered white key should not be pressed
                    } else {
                        keyToReward = key  // white key pressed, but scan further if 'covering' black key also pressed
                    }
                }
            }
        }
        
        if let key = keyToReward {  // no black key is pressed, so handle the pressed white key
            key.pressKey()
        }
    }
    
    // MARK: - KeyDelegate
    
    func keyPress(key: KeyView) {
        key.pressed = polyphonicMode ? -1 : +1
        delegate?.noteOn(key.tag)
        lastKeyPressed = key
    }
    
    func keyRelease(key: KeyView) {
        delegate?.noteOff(key.tag)
        lastKeyPressed = nil
    }
    
    func lastKeyRelease() {
        if !polyphonicMode {
            lastKeyPressed?.releaseKey() // release lastkey if set -> resets automatic lastKeyPressed
        }
    }
}


// Simple, understandable rouding
func RoundSimple(getal : CGFloat, decimalen: Int) -> CGFloat {
    // hoe ingewikkeld kun je het soms maken, Apple?
    let macht10 = CGFloat(pow(10, Double(decimalen)))
    return CGFloat(round(getal * macht10) / macht10)
}

