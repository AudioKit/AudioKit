//
//  AKKeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import Cocoa

public protocol AKKeyboardDelegate {
    func noteOn(_ note: Int)
    func noteOff(_ note: Int)
}

public class AKKeyboardView: NSView, AKMIDIListener {

    override public var isFlipped: Bool {
        get { return true }
    }

    let whiteKeyOff = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
    let blackKeyOff = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
    let keyOnColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    let topWhiteKeyOff = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0)

    public var delegate: AKKeyboardDelegate?

    var size = CGSize.zero
    var topKeyHeightRatio: CGFloat = 0.5
    var xOffset: CGFloat = 1
    var onKeys = Set<MIDINoteNumber>()

    var octaveCount = 3
    var firstOctave = 4

    public var polyphonicMode = false {
        didSet {
            for note in onKeys {
                delegate?.noteOff(note)
            }
            onKeys.removeAll()
            needsDisplay = true
        }
    }

    let midi = AKMIDI()

    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]
    let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]

    override public func draw(_ dirtyRect: NSRect) {
        for i in 0 ..< octaveCount {
            drawOctaveCanvas(i)
        }
        let backgroundPath = NSBezierPath(rect: NSMakeRect(size.width * CGFloat(octaveCount), 0, size.width / 7, size.height))
        NSColor.black.setFill()
        backgroundPath.fill()

        let lastC = NSBezierPath(rect:
            CGRect(x: whiteKeyX(0, octaveNumber: octaveCount), y: 1, width: whiteKeySize.width - 2, height: whiteKeySize.height))
        whiteKeyColor(0, octaveNumber: octaveCount).setFill()
        lastC.fill()
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

    func whiteKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset + size.width * CGFloat(octaveNumber)
    }

    func topKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset + size.width * CGFloat(octaveNumber)
    }

    func whiteKeyColor(_ n: Int, octaveNumber: Int) -> NSColor {
        return onKeys.contains((firstOctave + octaveNumber) * 12 + whiteKeyNotes[n]) ? keyOnColor : whiteKeyOff
    }

    func topKeyColor(_ n: Int, octaveNumber: Int) -> NSColor {
        if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
            return onKeys.contains((firstOctave + octaveNumber) * 12 + topKeyNotes[n]) ? keyOnColor : blackKeyOff
        }
        return topWhiteKeyOff

    }

    func drawOctaveCanvas(_ octaveNumber: Int) {
        //// background Drawing
        let backgroundPath = NSBezierPath(rect: NSMakeRect(0 + size.width * CGFloat(octaveNumber), 0, size.width, size.height))
        NSColor.black.setFill()
        backgroundPath.fill()

        var whiteKeysPaths = [NSBezierPath]()

        for i in 0 ..< 7 {
            whiteKeysPaths.append(
                NSBezierPath(rect: NSMakeRect(whiteKeyX(i, octaveNumber: octaveNumber), 1, whiteKeySize.width - 1, whiteKeySize.height))
            )
            whiteKeyColor(i, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[i].fill()
        }

        var topKeyPaths = [NSBezierPath]()

        for i in 0 ..< 28 {
            topKeyPaths.append(
                NSBezierPath(rect: NSMakeRect(topKeyX(i, octaveNumber: octaveNumber), 1, topKeySize.width, topKeySize.height))
            )
            topKeyColor(i, octaveNumber: octaveNumber).setFill()
            topKeyPaths[i].fill()
        }
    }


    public init(width: Int, height: Int, firstOctave: Int = 4, octaveCount: Int = 3,
                polyphonic: Bool = false) {
        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        size = CGSize(width: width / octaveCount - width/(octaveCount * octaveCount * 7), height: Double(height))
        midi.openInput()
        midi.addListener(self)
        needsDisplay = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func GetNoteName(_ note: Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    func noteFromEvent(_ event: NSEvent) -> MIDINoteNumber {

        let x = event.locationInWindow.x - self.frame.origin.x - xOffset
        let y = event.locationInWindow.y - self.frame.origin.y

        var note = 0

        if y < size.height * (1.0  - topKeyHeightRatio) {
            let octNum = Int(x / size.width)
            let scaledX = x - CGFloat(octNum) * size.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))]
        } else {
            let octNum = Int(x / size.width)
            let scaledX = x - CGFloat(octNum) * size.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))]
        }
        return note
    }

    override public func mouseDown(with event: NSEvent) {
        let note = noteFromEvent(event)
        if polyphonicMode && onKeys.contains(note) {
            onKeys.remove(note)
            delegate?.noteOff(note)
        } else {
            onKeys.insert(note)
            delegate?.noteOn(note)
        }
        needsDisplay = true
    }

    override public func mouseUp(with event: NSEvent) {
        if !polyphonicMode {
            let note = noteFromEvent(event)
            onKeys.remove(note)
            delegate?.noteOff(note)
        }
        needsDisplay = true
    }


    override public func mouseDragged(with event: NSEvent) {

        if polyphonicMode { return } // no response for 'drawing cursor' in polyphonic mode

        let note = noteFromEvent(event)
        if !onKeys.contains(note) {
            let currentNote = onKeys.first
            onKeys.removeAll()
            onKeys.insert(note)
            delegate?.noteOn(note)
            if let currNote = currentNote {
                delegate?.noteOff(currNote)
            }
            needsDisplay = true
        }

    }

    // MARK: - MIDI

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async(execute: {
            self.onKeys.insert(noteNumber)
            self.delegate?.noteOn(noteNumber)
            self.needsDisplay = true
        })
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async(execute: {
            self.onKeys.remove(noteNumber)
            self.delegate?.noteOff(noteNumber)
            self.needsDisplay = true
        })
    }
    public func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel) {
        if controller == Int(AKMIDIControl.damperOnOff.rawValue) && value == 0 {
            for note in onKeys {
                delegate?.noteOff(note)
            }
        }
    }
}
