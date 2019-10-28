//
//  AKPropertyControl.swift
//  AudioKit For macOS
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

@IBDesignable open class AKPropertyControl: NSView {
    override open func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }

    var initialValue: Double = 0

    func closest(to userValue: Double) -> Double {
        var index = 0
        var minimum: Double = 1_000_000

        for i in 0 ..< discreteValues.count {
            if abs(discreteValues[i] - userValue) < minimum {
                minimum = abs(discreteValues[i] - userValue)
                index = i
            }
        }
        return discreteValues[index]
    }

    /// Current value of the control
    @IBInspectable public var value: Double = 0 {
        didSet {
            value = range.clamp(value)
            if discreteValues.isNotEmpty {
                value = closest(to: value)
            }

            val = value.normalized(from: range, taper: taper)
        }
    }

    public var val: Double = 0 {
        didSet {
            needsDisplay = true
        }
    }

    public var range: ClosedRange<Double> = 0 ... 1 {
        didSet {
            val = value.normalized(from: range, taper: taper)
        }
    }

    public var taper: Double = 1 // Default Linear

    /// Text shown on the control
    @IBInspectable public var property: String = "Property"

    /// Format for the number shown on the control
    @IBInspectable public var format: String = "%0.3f"

    /// Font size
    @IBInspectable public var fontSize: CGFloat = 20

    /// Function to call when value changes
    public var callback: ((Double) -> Void) = { _ in }

    // Only integer
    public var discreteValues: [Double]  = []

    // Current dragging state, used to show/hide the value bubble
    public var isDragging: Bool = false

    public var lastTouch = CGPoint.zero

    public init(property: String,
                value: Double = 0.0,
                range: ClosedRange<Double> = 0 ... 1,
                taper: Double = 1,
                format: String = "%0.3f",
                frame: CGRect = CGRect(width: 440, height: 60),
                callback: @escaping (_ x: Double) -> Void = { _ in }) {
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

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        self.wantsLayer = true
    }

    override open func mouseDown(with theEvent: NSEvent) {
        isDragging = true
        mouseDragged(with: theEvent)
    }

    override open func mouseDragged(with theEvent: NSEvent) {
        // Override in subclass
    }

    open override func mouseUp(with theEvent: NSEvent) {
        isDragging = false
        needsDisplay = true
    }

    public func randomize() -> Double {
        value = random(in: range)
        needsDisplay = true
        return value
    }

}
