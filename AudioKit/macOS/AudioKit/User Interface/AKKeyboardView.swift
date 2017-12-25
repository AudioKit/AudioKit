//
//  AKKeyboardView.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public protocol AKKeyboardDelegate: class {
    func noteOn(note: MIDINoteNumber)
    func noteOff(note: MIDINoteNumber)
}

public class AKKeyboardView: NSView, AKMIDIListener {

    override public var isFlipped: Bool {
        return true
    }

    var size = CGSize.zero

    @IBInspectable open var octaveCount: Int = 2
    @IBInspectable open var firstOctave: Int = 4

    @IBInspectable open var topKeyHeightRatio: CGFloat = 0.55
    @IBInspectable open var polyphonicButton: NSColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

    @IBInspectable open var  whiteKeyOff: NSColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    @IBInspectable open var  blackKeyOff: NSColor = #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    @IBInspectable open var  keyOnColor: NSColor = #colorLiteral(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)
    @IBInspectable open var  topWhiteKeyOff: NSColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)

    open weak var delegate: AKKeyboardDelegate?

    var oneOctaveSize = CGSize.zero
    var xOffset: CGFloat = 1
    var onKeys = Set<MIDINoteNumber>()

    public var polyphonicMode = false {
        didSet {
            for note in onKeys {
                delegate?.noteOff(note: note)
            }
            onKeys.removeAll()
            needsDisplay = true
        }
    }

    let midi = AudioKit.midi

    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]
    let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]

    override public func draw(_ dirtyRect: NSRect) {
        for i in 0 ..< octaveCount {
            drawOctaveCanvas(octaveNumber: i)
        }
        let backgroundPath = NSBezierPath(rect: NSRect(x: size.width * CGFloat(octaveCount),
                                                       y: 0,
                                                       width: size.width / 7,
                                                       height: size.height))
        NSColor.black.setFill()
        backgroundPath.fill()

        let lastC = NSBezierPath(rect:
            CGRect(x: whiteKeyX(n: 0, octaveNumber: octaveCount),
                   y: 1,
                   width: whiteKeySize.width - 2,
                   height: whiteKeySize.height))
        whiteKeyColor(n: 0, octaveNumber: octaveCount).setFill()
        lastC.fill()
    }

    var whiteKeySize: NSSize {
        return NSSize(width: size.width / 7.0,
                      height: size.height - 2)
    }

    var topKeySize: NSSize {
        return NSSize(width: size.width / (4 * 7),
                      height: size.height * topKeyHeightRatio)
    }

    func whiteKeyX(n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset + size.width * CGFloat(octaveNumber)
    }

    func topKeyX(n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset + size.width * CGFloat(octaveNumber)
    }

    func whiteKeyColor(n: Int, octaveNumber: Int) -> NSColor {
        return onKeys.contains(MIDINoteNumber((firstOctave + octaveNumber) * 12 + whiteKeyNotes[n])) ?
            keyOnColor : whiteKeyOff
    }

    func topKeyColor(n: Int, octaveNumber: Int) -> NSColor {
        if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
            return onKeys.contains(MIDINoteNumber((firstOctave + octaveNumber) * 12 + topKeyNotes[n])) ?
                keyOnColor : blackKeyOff
        }
        return topWhiteKeyOff

    }

    func drawOctaveCanvas(octaveNumber: Int) {
        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSRect(x: 0 + size.width * CGFloat(octaveNumber),
                                                       y: 0,
                                                       width: size.width,
                                                       height: size.height))
        NSColor.black.setFill()
        backgroundPath.fill()

        var whiteKeysPaths = [NSBezierPath]()

        for i in 0 ..< 7 {
            whiteKeysPaths.append(
                NSBezierPath(rect: NSRect(x: whiteKeyX(n: i, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: whiteKeySize.width - 1,
                                          height: whiteKeySize.height))
            )
            whiteKeyColor(n: i, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[i].fill()
        }

        var topKeyPaths = [NSBezierPath]()

        for i in 0 ..< 28 {
            topKeyPaths.append(
                NSBezierPath(rect: NSRect(x: topKeyX(n: i, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: topKeySize.width,
                                          height: topKeySize.height))
            )
            topKeyColor(n: i, octaveNumber: octaveNumber).setFill()
            topKeyPaths[i].fill()
        }
    }

    public init(width: Int,
                height: Int,
                firstOctave: Int = 4,
                octaveCount: Int = 3,
                polyphonic: Bool = false) {
        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        size = CGSize(width: width / octaveCount - width / (octaveCount * octaveCount * 7), height: Double(height))
        needsDisplay = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Storyboard Rendering

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))
    }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: 1_024, height: 84)
    }

    public func getNoteName(note: Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    func noteFromEvent(event: NSEvent) -> MIDINoteNumber {

        let x = event.locationInWindow.x - self.frame.origin.x - xOffset
        let y = event.locationInWindow.y - self.frame.origin.y

        var note = 0

        if y < size.height * (1.0 - topKeyHeightRatio) {
            let octNum = Int(x / size.width)
            let scaledX = x - CGFloat(octNum) * size.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))]
        } else {
            let octNum = Int(x / size.width)
            let scaledX = x - CGFloat(octNum) * size.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))]
        }
        return MIDINoteNumber(note)
    }

    override public func mouseDown(with event: NSEvent) {
        let note = noteFromEvent(event: event)
        if polyphonicMode && onKeys.contains(note) {
            onKeys.remove(note)
            delegate?.noteOff(note: note)
        } else {
            onKeys.insert(note)
            delegate?.noteOn(note: note)
        }
        needsDisplay = true
    }

    override public func mouseUp(with event: NSEvent) {
        if !polyphonicMode {
            let note = noteFromEvent(event: event)
            onKeys.remove(note)
            delegate?.noteOff(note: note)
        }
        needsDisplay = true
    }

    override public func mouseDragged(with event: NSEvent) {

        if polyphonicMode {
            return
        } // no response for 'drawing cursor' in polyphonic mode

        let note = noteFromEvent(event: event)
        if !onKeys.contains(note) {
            let currentNote = onKeys.first
            onKeys.removeAll()
            onKeys.insert(note)
            delegate?.noteOn(note: note)
            if let currNote = currentNote {
                delegate?.noteOff(note: currNote)
            }
            needsDisplay = true
        }

    }

    // MARK: - MIDI

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                                   velocity: MIDIVelocity,
                                   channel: MIDIChannel) {
        DispatchQueue.main.async(execute: {
            self.onKeys.insert(noteNumber)
            self.delegate?.noteOn(note: noteNumber)
            self.needsDisplay = true
        })
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                                    velocity: MIDIVelocity,
                                    channel: MIDIChannel) {
        DispatchQueue.main.async(execute: {
            self.onKeys.remove(noteNumber)
            self.delegate?.noteOff(note: noteNumber)
            self.needsDisplay = true
        })
    }
    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte,
                                       channel: MIDIChannel) {
        if controller == MIDIByte(AKMIDIControl.damperOnOff.rawValue) && value == 0 {
            for note in onKeys {
                delegate?.noteOff(note: note)
            }
        }
    }
    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel) {
        // do nothing
    }
}
