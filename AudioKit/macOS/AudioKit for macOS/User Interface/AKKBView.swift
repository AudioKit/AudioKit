//
//  AKKBView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 8/7/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

//
//  AKKeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//
//  31 July 2016
//  Adapted by Jop van der Werff to resemble a bit more a real-world keyboard
//  This KeyboardView also will begin with a white key and end with a white key
//  according real-world keyboards, but also to function well for the code implemented

import Cocoa

public protocol AKKBDelegate {
    func noteOn(note: Int)
    func noteOff(note: Int)
//    func allNotesOff()  // for stuff like pedal release, panic
}

public class AKKBView: NSView, AKMIDIListener {
    
    override public var flipped: Bool {
        get {
            return true
        }
    }
    
    let whiteKeyOff = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
    let blackKeyOff = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
    let keyOnColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    let topWhiteKeyOff = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0)
    
    var size = CGSizeZero
    var topKeyHeightRatio: CGFloat = 0.75
    var xOffset: CGFloat = 1
    var topKeyStroke: CGFloat = 0
    var keyStates = [false, false, false, false, false, false, false, false, false, false, false, false]
    
    public var polyphonicMode = false {
        didSet {
        }
    }
    
    let midi = AKMIDI()
    
    
    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0,0,0,1,1,2,2,3,3,4,4,4,5,5,5,6,6,7,7,8,8,9,9,10,10,11,11,11]
    
    
    override public func drawRect(dirtyRect: NSRect) {
        drawOctaveCanvas(0)
    }
    
    var whiteKeySize: NSSize {
        get {
            return NSMakeSize(size.width / 7.0, size.height - 2)
        }
    }
    
    var topKeySize: NSSize {
        get {
            return NSMakeSize(size.width / (4 * 7), size.height * topKeyHeightRatio)
        }
    }
    
    func whiteKeyX(n: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset
    }
    
    func topKeyX(n: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset
    }
    
    func whiteKeyColor(n: Int) -> NSColor {
        return keyStates[n] ? keyOnColor : whiteKeyOff
    }
    
    func topKeyColor(n: Int) -> NSColor {
        var keyOffColor = topWhiteKeyOff
        if notesWithSharps[topKeyNotes[n]].rangeOfString("#") != nil {
            keyOffColor = blackKeyOff
        }
        return keyStates[topKeyNotes[n]] ? keyOnColor : keyOffColor
    }
    
    func drawOctaveCanvas(octaveNumber: Int) {
        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSMakeRect(0, 0, size.width, size.height))
        NSColor.blueColor().setFill()
        backgroundPath.fill()
        
        var whiteKeysPaths = [NSBezierPath]()
        
        for i in 0 ..< 7 {
            whiteKeysPaths.append(
                NSBezierPath(rect: NSMakeRect(whiteKeyX(i), 1, whiteKeySize.width * 39.0 / 40.0, whiteKeySize.height))
            )
            whiteKeyColor(i).setFill()
            whiteKeysPaths[i].fill()
        }
        
        var topKeyPaths = [NSBezierPath]()
        
        for i in 0 ..< 28 { 
            topKeyPaths.append(
                NSBezierPath(rect: NSMakeRect(topKeyX(i), 0, topKeySize.width, topKeySize.height))
            )
            topKeyColor(i).setFill()
            topKeyPaths[i].fill()
            topKeyColor(i).setStroke()
            topKeyPaths[i].lineWidth = topKeyStroke
            topKeyPaths[i].stroke()
        }
    }

    
    public init(width: Int, height: Int, firstOctave: Int, octaveCount: Int,
                polyphonic: Bool = false) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        size = CGSize(width: width, height: height)
        midi.openInput()
        midi.addListener(self)
        needsDisplay = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func GetNoteName(note : Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }
    
    override public func mouseDown(event: NSEvent) {
        let x = event.locationInWindow.x - self.frame.origin.x - xOffset
        let y = event.locationInWindow.y - self.frame.origin.y
        
        if y < size.height * (1.0  - topKeyHeightRatio) {
            dump(naturalNotes[Int(floor(x / whiteKeySize.width))])
        } else {
            dump(notesWithSharps[topKeyNotes[Int(floor(x / topKeySize.width))]])
        }
    }
    
    override public func mouseUp(event: NSEvent) {
    }
    

    override public func mouseDragged(event: NSEvent) {
        
        let x = event.locationInWindow.x - self.frame.origin.x
        let y = event.locationInWindow.y - self.frame.origin.y
        
        needsDisplay = true
        if polyphonicMode { return } // no response for 'drawing cursor' in polyphonic mode
        
        //determine which key is currently pressed, if any
    
    }
    
    // MARK: - MIDI
    
    public func receivedMIDINoteOn(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//        for key in keys {
//            if key.midiNote == noteNumber {
//                dispatch_async(dispatch_get_main_queue(), {
//                    key.pressKey()
//                })
//            }
//        }
    }
    
    public func receivedMIDINoteOff(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//        for key in keys {
//            if key.midiNote == noteNumber {
//                dispatch_async(dispatch_get_main_queue(), {
//                })
//            }
//        }
    }
}

