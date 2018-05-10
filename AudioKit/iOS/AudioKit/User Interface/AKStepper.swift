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
    var label: UILabel! //fixme
    var valueLabel: UILabel? //fixme
    var showsValue: Bool = true
    var plusButton: AKButton!
    var minusButton: AKButton!
    @IBInspectable public var currentValue: Double = 0.5 {
        didSet{
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
        print("callback: \(val)")
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
        if showsValue {
            addSubview(valueLabel!)
        }
    }

    /// Initialize within Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        checkValues()
        self.originalValue = currentValue
        generateUIComponents(frame: frame)
        setupButtons(frame: frame)
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    override open func awakeFromNib() {
        checkValues()
        super.awakeFromNib()
    }
    /// Draw the stepper
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    private func genStackViews(rect: CGRect) {
        let borderWidth = minusButton!.borderWidth
        label.frame = CGRect(x: rect.origin.x + borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3)
        label.text = text
        label.textAlignment = .left
        valueLabel?.frame = CGRect(x: rect.origin.x - borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3)
        valueLabel?.text = "\(currentValue)"
        valueLabel?.textAlignment = .right
        
        let buttons = UIStackView(frame: CGRect(x: rect.origin.x, y: rect.origin.y + label.frame.height, width: rect.width, height: rect.height * 0.7))
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 1
        
        addToStackIfPossible(view: minusButton, stack: buttons)
        addToStackIfPossible(view: plusButton, stack: buttons)
        self.addSubview(buttons)
    }
    private func generateUIComponents(frame: CGRect){
        //frame will be overridden w draw function
        label = UILabel(frame: frame)
        valueLabel = UILabel(frame: frame)
    }
    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        minusButton?.setNeedsDisplay()
        plusButton?.setNeedsDisplay()
    }
    private func addToStackIfPossible(view: UIView?, stack: UIStackView) {
        if view != nil {
            stack.addArrangedSubview(view!)
        }
    }
    internal func checkValues() {
        assert(minimum < maximum)
        assert(currentValue >= minimum)
        assert(currentValue <= maximum)
        assert(increment < maximum - minimum)
        originalValue = currentValue
    }
    internal var buttonFrame: CGRect {
        return CGRect(x: frame.origin.x, y: frame.origin.y + label.frame.height, width: frame.width / 2, height: frame.height * 0.7)
    }
    internal func setupButtons(frame: CGRect) {
        plusButton = AKButton(title: "+", frame: frame, callback: {_ in
            self.doPlusAction()
            self.touchBeganCallback()
        })
        plusButton.releaseCallback = {_ in
            self.touchEndedCallback()
        }
        minusButton = AKButton(title: "-", frame: frame, callback: {_ in
            self.doMinusAction()
            self.touchBeganCallback()
        })
        minusButton.releaseCallback = {_ in
            self.touchEndedCallback()
        }
    }
    open var touchBeganCallback: () -> Void = { }
    open var touchEndedCallback: () -> Void = { }
}
