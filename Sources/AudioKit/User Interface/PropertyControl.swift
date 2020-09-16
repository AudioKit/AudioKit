// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)

import UIKit
import AVFoundation

@IBDesignable public class AKPropertyControl: UIView {

    var initialValue: AUValue = 0

    func closest(to userValue: AUValue) -> AUValue {
        var index = 0
        var minimum: AUValue = 1_000_000

        for discreteValueIndex in 0 ..< discreteValues.count {
            if abs(discreteValues[discreteValueIndex] - userValue) < minimum {
                minimum = abs(discreteValues[discreteValueIndex] - userValue)
                index = discreteValueIndex
            }
        }
        return discreteValues[index]
    }

    /// Current value of the control
    public var value: AUValue = 0 {
        didSet {
            value = range.clamp(value)
            if discreteValues.isNotEmpty {
                value = closest(to: value)
            }

            val = value.normalized(from: range, taper: taper)
        }
    }

    public var val: AUValue = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var range: ClosedRange<AUValue> = 0 ... 1 {
        didSet {
            val = value.normalized(from: range, taper: taper)
        }
    }

    public var taper: AUValue = 1 // Default Linear

    /// Text shown on the control
    @IBInspectable public var property: String = "Property"

    /// Format for the number shown on the control
    @IBInspectable public var format: String = "%0.3f"

    /// Font size
    @IBInspectable public var fontSize: CGFloat = 20

    /// Function to call when value changes
    public var callback: ((AUValue) -> Void) = { _ in }

    // Only integer
    public var discreteValues: [AUValue]  = []

    // Current dragging state, used to show/hide the value bubble
    public var isDragging: Bool = false

    public var lastTouch = CGPoint.zero

    public init(property: String,
                value: AUValue = 0.0,
                range: ClosedRange<AUValue> = 0 ... 1,
                taper: AUValue = 1,
                format: String = "%0.3f",
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: @escaping (_ x: AUValue) -> Void = { _ in }) {
        self.value = value
        self.initialValue = value
        self.range = range
        self.taper = taper
        self.property = property
        self.format = format

        self.callback = callback
        super.init(frame: frame)

        self.val = value.normalized(from: range, taper: taper)

        setNeedsDisplay()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /// Initialization within Interface Builder
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    /// Handle new touches
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = true
        touchesMoved(touches, with: event)
    }

    /// Handle moved touches
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        setNeedsDisplay()
    }

    /// Handle touches ended
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }

    }

    public func randomize() -> AUValue {
        value = AUValue(random(in: range))
        setNeedsDisplay()
        return value
    }

}

#else

import Cocoa
import AVFoundation

@IBDesignable public class AKPropertyControl: NSView {
    override public func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }

    var initialValue: AUValue = 0

    func closest(to userValue: AUValue) -> AUValue {
        var index = 0
        var minimum: AUValue = 1_000_000

        for i in 0 ..< discreteValues.count {
            if abs(discreteValues[i] - userValue) < minimum {
                minimum = abs(discreteValues[i] - userValue)
                index = i
            }
        }
        return discreteValues[index]
    }

    /// Current value of the control
    public var value: AUValue = 0 {
        didSet {
            value = range.clamp(value)
            if discreteValues.isNotEmpty {
                value = closest(to: value)
            }

            val = value.normalized(from: range, taper: taper)
        }
    }

    public var val: AUValue = 0 {
        didSet {
            needsDisplay = true
        }
    }

    public var range: ClosedRange<AUValue> = 0 ... 1 {
        didSet {
            val = value.normalized(from: range, taper: taper)
        }
    }

    public var taper: AUValue = 1 // Default Linear

    /// Text shown on the control
    @IBInspectable public var property: String = "Property"

    /// Format for the number shown on the control
    @IBInspectable public var format: String = "%0.3f"

    /// Font size
    @IBInspectable public var fontSize: CGFloat = 20

    /// Function to call when value changes
    public var callback: ((AUValue) -> Void) = { _ in }

    // Only integer
    public var discreteValues: [AUValue]  = []

    // Current dragging state, used to show/hide the value bubble
    public var isDragging: Bool = false

    public var lastTouch = CGPoint.zero

    public init(property: String,
                value: AUValue = 0.0,
                range: ClosedRange<AUValue> = 0 ... 1,
                taper: AUValue = 1,
                format: String = "%0.3f",
                frame: CGRect = CGRect(width: 440, height: 60),
                callback: @escaping (_ x: AUValue) -> Void = { _ in }) {
        self.value = value
        self.initialValue = value
        self.range = range
        self.taper = taper
        self.property = property
        self.format = format

        self.callback = callback
        super.init(frame: frame)

        self.val = value.normalized(from: range, taper: taper)

        self.wantsLayer = true

        needsDisplay = true
    }

    /// Initialization within Interface Builder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        self.wantsLayer = true
    }

    override public func mouseDown(with theEvent: NSEvent) {
        isDragging = true
        mouseDragged(with: theEvent)
    }

    override public func mouseDragged(with theEvent: NSEvent) {
        // Override in subclass
    }

    public override func mouseUp(with theEvent: NSEvent) {
        isDragging = false
        needsDisplay = true
    }

    public func randomize() -> AUValue {
        value = random(in: range)
        needsDisplay = true
        return value
    }

}
#endif
