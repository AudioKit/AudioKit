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

@IBDesignable public class AKKeyboardView: UIView, AKMIDIListener {

    @IBInspectable public var octaveCount: Int = 2
    @IBInspectable public var firstOctave: Int = 4
    @IBInspectable public var topKeyHeightRatio: CGFloat = 0.55

    @IBInspectable public var  whiteKeyOff: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    @IBInspectable public var  blackKeyOff: UIColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    @IBInspectable public var  keyOnColor: UIColor = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    public var delegate: AKKeyboardDelegate?
    
    var oneOctaveSize = CGSizeZero
    var xOffset: CGFloat = 1
    var onKeys = Set<MIDINoteNumber>()
    
    
    public var polyphonicMode = false {
        didSet {
            for note in onKeys {
                delegate?.noteOff(note)
            }
            onKeys.removeAll()
            setNeedsDisplay()
        }
    }
    
    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0,0,0,1,1,2,2,3,3,4,4,4,5,5,5,6,6,7,7,8,8,9,9,10,10,11,11,11]
    let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]
    
    func getNoteName(note: Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    
    // MARK: - Initialization
    
    public init(width: Int, height: Int, firstOctave: Int = 4, octaveCount: Int = 3,
                polyphonic: Bool = false) {
        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        oneOctaveSize = CGSize(width: width / octaveCount - width / (octaveCount * octaveCount * 7), height: Double(height))
        setNeedsDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: width / octaveCount - width / (octaveCount * octaveCount * 7), height: Double(height))
        contentMode = .Redraw
    }
    
    // MARK: - Storyboard Rendering
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        contentMode = .Redraw
        clipsToBounds = true
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: 440, height: 150)
    }
    
    public class override func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    // MARK: - Drawing
    
    override public func drawRect(rect: CGRect) {
        for i in 0 ..< octaveCount {
            drawOctaveCanvas(i)
        }
        
        let backgroundPath = UIBezierPath(rect: CGRect(x: oneOctaveSize.width * CGFloat(octaveCount), y: 0, width: oneOctaveSize.width / 7.0, height: oneOctaveSize.height))
        UIColor.blackColor().setFill()
        backgroundPath.fill()
        
        let lastC = UIBezierPath(rect:
            CGRect(x: whiteKeyX(0, octaveNumber: octaveCount), y: 1, width: whiteKeySize.width - 2, height: whiteKeySize.height))
        whiteKeyColor(0, octaveNumber: octaveCount).setFill()
        lastC.fill()
        
    }
    
    func drawOctaveCanvas(octaveNumber: Int) {
        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0 + oneOctaveSize.width * CGFloat(octaveNumber), y: 0, width: oneOctaveSize.width, height: oneOctaveSize.height))
        UIColor.blackColor().setFill()
        backgroundPath.fill()
        
        var whiteKeysPaths = [UIBezierPath]()
        
        for i in 0 ..< 7 {
            whiteKeysPaths.append(
                UIBezierPath(rect: CGRect(x: whiteKeyX(i, octaveNumber: octaveNumber), y: 1, width: whiteKeySize.width - 1, height: whiteKeySize.height))
            )
            whiteKeyColor(i, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[i].fill()
        }
        
        var topKeyPaths = [UIBezierPath]()
        
        for i in 0 ..< 28 {
            topKeyPaths.append(
                UIBezierPath(rect: CGRect(x: topKeyX(i, octaveNumber: octaveNumber), y: 1, width: topKeySize.width, height: topKeySize.height))
            )
            topKeyColor(i, octaveNumber: octaveNumber).setFill()
            topKeyPaths[i].fill()
        }
    }
    
    
    // MARK: - Touch Handling
    
    func notesFromTouches(touches: Set<UITouch>) -> [MIDINoteNumber] {
        var notes = [MIDINoteNumber]()
        for touch in touches {
            let scaledTouch =  touch.locationInView(self)
            let x = scaledTouch.x - xOffset
            let y = scaledTouch.y
        
            var note = 0
            
            if y > oneOctaveSize.height * topKeyHeightRatio {
                let octNum = Int(x / oneOctaveSize.width)
                let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
                note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))]
            } else {
                let octNum = Int(x / oneOctaveSize.width)
                let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
                note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))]
            }
            if note != 0 { notes.append(note) }
        }
        return notes
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let notes = notesFromTouches(touches)
        for note in notes {
            if polyphonicMode && onKeys.contains(note) {
                onKeys.remove(note)
                delegate?.noteOff(note)
            } else {
                onKeys.insert(note)
                delegate?.noteOn(note)
            }
        }
        setNeedsDisplay()
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !polyphonicMode {
            let notes = notesFromTouches(touches)
            for note in notes {
                onKeys.remove(note)
                delegate?.noteOff(note)
            }
        }
        setNeedsDisplay()
    }
    
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if polyphonicMode { return } // no response for 'drawing cursor' in polyphonic mode
        
        let notes = notesFromTouches(touches)
        for note in notes {
            if !onKeys.contains(note) {
                let currentNote = onKeys.first
                onKeys.removeAll()
                onKeys.insert(note)
                delegate?.noteOn(note)
                if let currNote = currentNote {
                    delegate?.noteOff(currNote)
                }
            }
        }
        setNeedsDisplay()
    }
    
    // MARK: - Private helper properties and functions
    
    var whiteKeySize: CGSize {
        get {
            return CGSize(width: oneOctaveSize.width / 7.0, height: oneOctaveSize.height - 2)
        }
    }
    
    var topKeySize: CGSize {
        get {
            return CGSize(width: oneOctaveSize.width / (4 * 7), height: oneOctaveSize.height * topKeyHeightRatio)
        }
    }
    
    func whiteKeyX(n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }
    
    func topKeyX(n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }
    
    func whiteKeyColor(n: Int, octaveNumber: Int) -> UIColor {
        return onKeys.contains((firstOctave + octaveNumber) * 12 + whiteKeyNotes[n]) ? keyOnColor : whiteKeyOff
    }
    
    func topKeyColor(n: Int, octaveNumber: Int) -> UIColor {
        if notesWithSharps[topKeyNotes[n]].rangeOfString("#") != nil {
            return onKeys.contains((firstOctave + octaveNumber) * 12 + topKeyNotes[n]) ? keyOnColor : blackKeyOff
        }
        return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
        
    }
}
