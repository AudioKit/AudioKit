//
//  AKStepper.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import UIKit

/// Incrementor view, normally used for MIDI presets, but could be useful elsehwere
@IBDesignable open class AKStepper: UIView {

    @IBInspectable var text: String = "Stepper"
    public var labelFont: UIFont? = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var valueFont: UIFont? = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var buttonFont: UIFont? = UIFont.boldSystemFont(ofSize: 24)
    @IBInspectable public var buttonBorderWidth: CGFloat = 3.0
    var label: UILabel! //fixme
    var valueLabel: UILabel? //fixme
    var buttons: UIStackView!
    var showsValue: Bool = true
    var plusButton: AKButton!
    var minusButton: AKButton!
    @IBInspectable public var currentValue: Double = 0.5 {
        didSet {
            DispatchQueue.main.async {
                self.valueLabel?.text = String(format: "%.3f", self.currentValue)
            }

        }
    }
    @IBInspectable public var increment: Double = 0.1
    @IBInspectable public var minimum: Double = 0
    @IBInspectable public var maximum: Double = 1
    internal var originalValue: Double = 0.5
    open var callback: (Double) -> Void = {val in
        AKLog("AKStepper callback: \(val)")
    }
    internal func doPlusAction() {
        currentValue += min(increment, maximum - currentValue)
        callback(currentValue)
    }
    internal func doMinusAction() {
        currentValue -= min(increment, currentValue - minimum)
        callback(currentValue)
    }
    /// Initialize the stepper view
    public init(text: String, value: Double, minimum: Double, maximum: Double, increment: Double,
                frame: CGRect, showsValue: Bool = true, callback: @escaping (Double) -> Void) {
        self.callback = callback
        self.minimum = minimum
        self.maximum = maximum
        self.increment = increment
        self.currentValue = value
        self.originalValue = value
        self.showsValue = showsValue
        self.text = text
        super.init(frame: frame)
        generateUIComponents(frame: frame)
        checkValues()
        setupButtons(frame: frame)
        addSubview(label)
        if showsValue, let valueLabel = valueLabel {
            addSubview(valueLabel)
        }
    }

    /// Initialize within Interface Builder
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateUIComponents(frame: frame)
        checkValues()
        setupButtons(frame: frame)
        self.originalValue = currentValue
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    open override func awakeFromNib() {
        checkValues()
        super.awakeFromNib()
    }
    /// Draw the stepper
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    private func genStackViews(rect: CGRect) {
        let borderWidth = minusButton?.borderWidth ?? 0
        label.frame = CGRect(x: rect.origin.x + borderWidth,
                             y: rect.origin.y,
                             width: rect.width,
                             height: rect.height * 0.3)
        label.text = text
        label.textAlignment = .left
        valueLabel?.frame = CGRect(x: rect.origin.x - borderWidth,
                                   y: rect.origin.y,
                                   width: rect.width,
                                   height: rect.height * 0.3)
        valueLabel?.text = "\(currentValue)"
        valueLabel?.textAlignment = .right
        buttons.frame = CGRect(x: rect.origin.x,
                               y: rect.origin.y + label.frame.height,
                               width: rect.width,
                               height: rect.height * 0.7)
    }
    private func generateUIComponents(frame: CGRect) {
        //frame will be overridden w draw function
        label = UILabel(frame: frame)
        label.font = labelFont
        valueLabel = UILabel(frame: frame)
        valueLabel?.font = valueFont
        buttons = UIStackView(frame: frame)
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 1
    }
    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        genStackViews(rect: bounds)
    }
    internal func addToStackIfPossible(view: UIView?, stack: UIStackView) {
        if let view = view {
            stack.addArrangedSubview(view)
        }
    }
    internal func checkValues() {
        assert(minimum < maximum)
        assert(currentValue >= minimum)
        assert(currentValue <= maximum)
        assert(increment < maximum - minimum)
        originalValue = currentValue
    }
    internal func setupButtons(frame: CGRect) {
        let buttonFrame = CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height)
        plusButton = AKButton(title: "+", frame: buttonFrame, callback: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doPlusAction()
            strongSelf.touchBeganCallback()
        })
        plusButton.releaseCallback = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        minusButton = AKButton(title: "-", frame: buttonFrame, callback: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.doMinusAction()
            strongSelf.touchBeganCallback()
        })
        minusButton.releaseCallback = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.touchEndedCallback()
        }
        plusButton.font = buttonFont ?? UIFont.systemFont(ofSize: 12)
        minusButton.font = buttonFont ?? UIFont.systemFont(ofSize: 12)
        plusButton.borderWidth = buttonBorderWidth
        minusButton.borderWidth = buttonBorderWidth
        addToStackIfPossible(view: minusButton, stack: buttons)
        addToStackIfPossible(view: plusButton, stack: buttons)
        self.addSubview(buttons)
    }
    open var touchBeganCallback: () -> Void = { }
    open var touchEndedCallback: () -> Void = { }
}
