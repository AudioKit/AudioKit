//
//  AKKeyboardView.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
import UIKit

/// Delegate for keyboard events
@objc public protocol AKKeyboardDelegate: class {
    /// Note on evenets
    func noteOn(note: MIDINoteNumber)
    /// Note off events
    func noteOff(note: MIDINoteNumber)
}

/// Clickable keyboard mainly used for AudioKit playgrounds
@IBDesignable open class AKKeyboardView: UIView, AKMIDIListener {

    /// Number of octaves displayed at once
    @IBInspectable open var octaveCount: Int = 2

    /// Lowest octave displayed
    @IBInspectable open var firstOctave: Int = 4

    /// Relative measure of the height of the black keys
    @IBInspectable open var topKeyHeightRatio: CGFloat = 0.55

    /// Color of the polyphonic toggle button
    @IBInspectable open var polyphonicButton: UIColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

    /// White key color
    @IBInspectable open var  whiteKeyOff: UIColor = #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

    /// Black key color
    @IBInspectable open var  blackKeyOff: UIColor = #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

    /// Activated key color
    @IBInspectable open var  keyOnColor: UIColor = #colorLiteral(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.000)

    /// Class to handle user actions
    open weak var delegate: AKKeyboardDelegate?

    var oneOctaveSize = CGSize.zero
    var xOffset: CGFloat = 1
    var onKeys = Set<MIDINoteNumber>()

    /// Allows multiple notes to play concurrently
    @objc open var polyphonicMode = false {
        didSet {
            for note in onKeys {
                delegate?.noteOff(note: note)
            }
            onKeys.removeAll()
            setNeedsDisplay()
        }
    }

    let baseMIDINote = 24 // MIDINote 24 is C0

    let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    let notesWithSharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let topKeyNotes = [0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 11]
    let whiteKeyNotes = [0, 2, 4, 5, 7, 9, 11]

    func getNoteName(_ note: Int) -> String {
        let keyInOctave = note % 12
        return notesWithSharps[keyInOctave]
    }

    // MARK: - Initialization

    /// Initialize the keyboard with default info
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }

    /// Initialize the keyboard
    @objc public init(width: Int,
                      height: Int,
                      firstOctave: Int = 4,
                      octaveCount: Int = 3,
                      polyphonic: Bool = false) {
        self.octaveCount = octaveCount
        self.firstOctave = firstOctave
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))
        isMultipleTouchEnabled = true
        setNeedsDisplay()
    }

    /// Initialization within Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }

    // MARK: - Storyboard Rendering

    /// Set up the view for rendering in Interface Builder
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        contentMode = .redraw
        clipsToBounds = true
    }

    /// Keyboard view size
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: 1_024, height: 84)
    }

    /// Require constraints
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Drawing

    /// Draw the view
    override open func draw(_ rect: CGRect) {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        for i in 0 ..< octaveCount {
            drawOctaveCanvas(i)
        }

        let tempWidth = CGFloat(width) - CGFloat((octaveCount * 7) - 1) * whiteKeySize.width - 1
        let backgroundPath = UIBezierPath(rect: CGRect(x: oneOctaveSize.width * CGFloat(octaveCount),
                                                       y: 0,
                                                       width: tempWidth,
                                                       height: oneOctaveSize.height))
        UIColor.black.setFill()
        backgroundPath.fill()

        let lastC = UIBezierPath(rect:
            CGRect(x: whiteKeyX(0, octaveNumber: octaveCount), y: 1, width: tempWidth, height: whiteKeySize.height))
        whiteKeyColor(0, octaveNumber: octaveCount).setFill()
        lastC.fill()

    }

    /// Draw one octave
    func drawOctaveCanvas(_ octaveNumber: Int) {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        //// background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0 + oneOctaveSize.width * CGFloat(octaveNumber),
                                                       y: 0,
                                                       width: oneOctaveSize.width,
                                                       height: oneOctaveSize.height))
        UIColor.black.setFill()
        backgroundPath.fill()

        var whiteKeysPaths = [UIBezierPath]()

        for i in 0 ..< 7 {
            whiteKeysPaths.append(
                UIBezierPath(rect: CGRect(x: whiteKeyX(i, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: whiteKeySize.width - 1,
                                          height: whiteKeySize.height))
            )
            whiteKeyColor(i, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[i].fill()
        }

        var topKeyPaths = [UIBezierPath]()

        for i in 0 ..< 28 {
            topKeyPaths.append(
                UIBezierPath(rect: CGRect(x: topKeyX(i, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: topKeySize.width,
                                          height: topKeySize.height))
            )
            topKeyColor(i, octaveNumber: octaveNumber).setFill()
            topKeyPaths[i].fill()
        }
    }

    // MARK: - Touch Handling

    func notesFromTouches(_ touches: Set<UITouch>) -> [MIDINoteNumber] {
        var notes = [MIDINoteNumber]()
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                notes.append(note)
            }
        }
        return notes
    }

    func noteFromTouchLocation(_ location: CGPoint ) -> MIDINoteNumber? {
        guard bounds.contains(location) else {
            return nil
        }

        let x = location.x - xOffset
        let y = location.y

        var note = 0

        if y > oneOctaveSize.height * topKeyHeightRatio {
            let octNum = Int(x / oneOctaveSize.width)
            let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))] + baseMIDINote
        } else {
            let octNum = Int(x / oneOctaveSize.width)
            let scaledX = x - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))] + baseMIDINote
        }
        if note >= 0 {
            return MIDINoteNumber(note)
        } else {
            return nil
        }

    }

    /// Handle new touches
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let notes = notesFromTouches(touches)
        for note in notes {
            pressAdded(note)
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle touches completed
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let note = noteFromTouchLocation(touch.location(in: self)) {
                // verify that there isn't still a touch remaining on same key from another finger
                if var otherTouches = event?.allTouches {
                    otherTouches.remove(touch)
                    if ❗️notesFromTouches(otherTouches).contains(note) {
                        pressRemoved(note, touches: event?.allTouches)
                    }
                }
            }
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle moved touches
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let key = noteFromTouchLocation(touch.location(in: self)),
                key != noteFromTouchLocation(touch.previousLocation(in: self)) {
                pressAdded(key)
                setNeedsDisplay()
            }
        }
        verifyTouches(event?.allTouches)
    }

    /// Handle stopped touches
    override open func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        verifyTouches(event?.allTouches)
    }

    // MARK: - Executing Key Presses

    private func pressAdded(_ newNote: MIDINoteNumber) {
        if ❗️polyphonicMode {
            for key in onKeys where key != newNote {
                pressRemoved(key)
            }
        }

        if ❗️onKeys.contains(newNote) {
            onKeys.insert(newNote)
            delegate?.noteOn(note: newNote)
        }

    }

    private func pressRemoved(_ note: MIDINoteNumber, touches: Set<UITouch>? = nil) {
        guard onKeys.contains(note) else {
            return
        }
        onKeys.remove(note)
        delegate?.noteOff(note: note)
        if ❗️polyphonicMode {
            // in mono mode, replace with note from highest remaining touch, if it exists
            var remainingNotes = notesFromTouches(touches ?? Set<UITouch>())
            remainingNotes = remainingNotes.filter { $0 != note }
            if let highest = remainingNotes.max() {
                pressAdded(highest)
            }
        }
    }

    private func verifyTouches(_ touches: Set<UITouch>?) {
        // check that current touches conforms to onKeys, remove stuck notes
        let notes = notesFromTouches(touches ?? Set<UITouch>() )
        let disjunct = onKeys.subtracting(notes)
        if disjunct.isNotEmpty {
            for note in disjunct {
                pressRemoved(note)
            }
        }
    }

    // MARK: - Private helper properties and functions

    var whiteKeySize: CGSize {
        return CGSize(width: oneOctaveSize.width / 7.0, height: oneOctaveSize.height - 2)
    }

    var topKeySize: CGSize {
        return CGSize(width: oneOctaveSize.width / (4 * 7), height: oneOctaveSize.height * topKeyHeightRatio)
    }

    // swiftlint:disable variable_name
    func whiteKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * whiteKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func topKeyX(_ n: Int, octaveNumber: Int) -> CGFloat {
        return CGFloat(n) * topKeySize.width + xOffset + oneOctaveSize.width * CGFloat(octaveNumber)
    }

    func whiteKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {
        return onKeys.contains(
            MIDINoteNumber((firstOctave + octaveNumber) * 12 + whiteKeyNotes[n] + baseMIDINote)
            ) ? keyOnColor : whiteKeyOff
    }

    func topKeyColor(_ n: Int, octaveNumber: Int) -> UIColor {
        if notesWithSharps[topKeyNotes[n]].range(of: "#") != nil {
            return onKeys.contains(
                MIDINoteNumber((firstOctave + octaveNumber) * 12 + topKeyNotes[n] + baseMIDINote)
                ) ? keyOnColor : blackKeyOff
        }
        return #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)

    }
}
