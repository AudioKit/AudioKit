// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if targetEnvironment(macCatalyst) || os(iOS)
import UIKit

/// Delegate for keyboard events
public protocol AKKeyboardDelegate: AnyObject {
    /// Note on events
    func noteOn(note: MIDINoteNumber)
    /// Note off events
    func noteOff(note: MIDINoteNumber)
}

/// Clickable keyboard mainly used for AudioKit playgrounds
@IBDesignable public class AKKeyboardView: UIView, AKMIDIListener {
    //swiftlint:disable
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
    var programmaticOnKeys = Set<MIDINoteNumber>()

    /// Allows multiple notes to play concurrently
    open var polyphonicMode = false {
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
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }

    /// Initialize the keyboard
    public init(width: Int,
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
        polyphonicMode = polyphonic
    }

    /// Initialization within Interface Builder
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }

    // MARK: - Storyboard Rendering

    /// Set up the view for rendering in Interface Builder
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        contentMode = .redraw
        clipsToBounds = true
    }

    /// Keyboard view size
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 0)
    }

    /// Require constraints
    public class override var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Drawing

    /// Draw the view
    public override func draw(_ rect: CGRect) {

        let width = Int(self.frame.width)
        let height = Int(self.frame.height)
        oneOctaveSize = CGSize(width: Double(width / octaveCount - width / (octaveCount * octaveCount * 7)),
                               height: Double(height))

        for index in 0 ..< octaveCount {
            drawOctaveCanvas(index)
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

        for index in 0 ..< 7 {
            whiteKeysPaths.append(
                UIBezierPath(rect: CGRect(x: whiteKeyX(index, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: whiteKeySize.width - 1,
                                          height: whiteKeySize.height))
            )
            whiteKeyColor(index, octaveNumber: octaveNumber).setFill()
            whiteKeysPaths[index].fill()
        }

        var topKeyPaths = [UIBezierPath]()

        for index in 0 ..< 28 {
            topKeyPaths.append(
                UIBezierPath(rect: CGRect(x: topKeyX(index, octaveNumber: octaveNumber),
                                          y: 1,
                                          width: topKeySize.width,
                                          height: topKeySize.height))
            )
            topKeyColor(index, octaveNumber: octaveNumber).setFill()
            topKeyPaths[index].fill()
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

        let xPoint = location.x - xOffset
        let yPoint = location.y

        var note = 0

        if yPoint > oneOctaveSize.height * topKeyHeightRatio {
            let octNum = Int(xPoint / oneOctaveSize.width)
            let scaledX = xPoint - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + whiteKeyNotes[max(0, Int(scaledX / whiteKeySize.width))] + baseMIDINote
        } else {
            let octNum = Int(xPoint / oneOctaveSize.width)
            let scaledX = xPoint - CGFloat(octNum) * oneOctaveSize.width
            note = (firstOctave + octNum) * 12 + topKeyNotes[max(0, Int(scaledX / topKeySize.width))] + baseMIDINote
        }
        if note >= 0 {
            return MIDINoteNumber(note)
        } else {
            return nil
        }

    }

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let notes = notesFromTouches(touches)
        for note in notes {
            pressAdded(note)
        }
        verifyTouches(event?.allTouches)
        setNeedsDisplay()
    }

    /// Handle touches completed
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
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

    // MARK: - Programmatic Key Pushes

    /// Programmatically trigger key press without calling delegate
    public func programmaticNoteOn(_ note: MIDINoteNumber) {
        programmaticOnKeys.insert(note)
        onKeys.insert(note)
        setNeedsDisplay()
    }

    /// Programatically remove key press without calling delegate
    ///
    /// Note: you can programmatically 'release' a note that has been pressed
    /// manually, but in such a case, the delegate.noteOff() will not be called
    /// when the finger is removed
    public func programmaticNoteOff(_ note: MIDINoteNumber) {
        programmaticOnKeys.remove(note)
        onKeys.remove(note)
        setNeedsDisplay()
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
                if ❗️programmaticOnKeys.contains(note) {
                    pressRemoved(note)
                }
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

#elseif os(macOS)

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

    let midi = AKMIDI()

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
        super.init(frame: CGRect(width: width, height: height))
        size = CGSize(width: Double(width) / Double(octaveCount) - Double(width) / Double(octaveCount * octaveCount * 7),
                      height: Double(height))
        needsDisplay = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Storyboard Rendering

    override public func prepareForInterfaceBuilder() {
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

#endif
