//
//  AKPropertyControl.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

@IBDesignable open class AKPropertyControl: UIView {

    var initialValue: Double = 0

    func closest(to userValue: Double) -> Double {
        var index = 0
        var minimum: Double = 1_000_000

        for discreteValueIndex in 0 ..< discreteValues.count {
            if abs(discreteValues[discreteValueIndex] - userValue) < minimum {
                minimum = abs(discreteValues[discreteValueIndex] - userValue)
                index = discreteValueIndex
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
            setNeedsDisplay()
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
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
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

        setNeedsDisplay()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /// Initialization within Interface Builder
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    /// Handle new touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = true
        touchesMoved(touches, with: event)
    }

    /// Handle moved touches
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        setNeedsDisplay()
    }

    /// Handle touches ended
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            isDragging = false
            setNeedsDisplay()
        }

    }

    public func randomize() -> Double {
        value = random(in: range)
        setNeedsDisplay()
        return value
    }

}
