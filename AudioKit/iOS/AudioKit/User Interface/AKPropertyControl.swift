// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import UIKit
import AudioKit

@IBDesignable open class AKPropertyControl: UIView {

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

    public func randomize() -> AUValue {
        value = AUValue(random(in: range))
        setNeedsDisplay()
        return value
    }

}
