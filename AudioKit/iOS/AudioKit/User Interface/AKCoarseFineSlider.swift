//
//  AKCoarseFineSlider.swift
//  AudioKitUI
//
//  Created by Jeff Cooper on 5/9/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

@IBDesignable open class AKCoarseFineSlider: UIView {

    @IBInspectable open var name: String = "CoarseFineSlider"
    public var titleFont: UIFont? = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var valueFont: UIFont? = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var buttonLabelFont: UIFont? = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var buttonFont: UIFont? = UIFont.boldSystemFont(ofSize: 24)
    @IBInspectable public var stringFormat: String = "%.3f"
    @IBInspectable public var buttonBorderWidth: CGFloat = 3.0
    var coarseStepper: AKStepper!
    var fineStepper: AKStepper!
    var slider: AKSlider!
    var nameLabel: UILabel!
    var valueLabel: UILabel!
    private var buttonPercent: CGFloat = 0.5
    private var labelPercent: CGFloat = 0.25
    internal var buttons: UIStackView!
    @IBInspectable public var minimum: Double = -2.0 {
        didSet {
            slider.range = minimum...maximum
            coarseStepper.minimum = minimum
            fineStepper.minimum = minimum
        }
    }
    @IBInspectable public var maximum: Double = 2.0 {
        didSet {
            slider.range = minimum...maximum
            coarseStepper.maximum = maximum
            fineStepper.maximum = maximum
        }
    }
    @IBInspectable public var coarseIncrement: Double = 1 {
        didSet { coarseStepper.increment = coarseIncrement }
    }
    @IBInspectable public var fineIncrement: Double = 0.1 {
        didSet { fineStepper.increment = fineIncrement }
    }
    @IBInspectable public var currentValue: Double = 1.0 {
        didSet {
            DispatchQueue.main.async {
                self.valueLabel.text = String(format: self.stringFormat, self.currentValue)
            }
        }
    }
    public var callback: (Double) -> Void = {val in
        print(val)
    }
    public func reset(to value: Double) {
        setStable(value: value)
        currentValue = value
        slider.value = value
    }
    public func setStable(value: Double) {
        coarseStepper.currentValue = value
        fineStepper.currentValue = value
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        genSubViews()
    }
    internal func genSubViews() {
        coarseStepper = AKStepper(text: "Coarse", value: currentValue, minimum: minimum, maximum: maximum, increment: coarseIncrement, frame: frame, showsValue: false, callback: { _ in })
        fineStepper = AKStepper(text: "Fine", value: currentValue, minimum: minimum, maximum: maximum, increment: fineIncrement, frame: frame, showsValue: false, callback: { _ in })
        slider = AKSlider(property: "", value: currentValue, range: minimum...maximum, taper: 1.0, format: "", color: AKStylist.sharedInstance.nextColor, frame: frame, callback: { _ in })
        coarseStepper.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.fineStepper.currentValue = value
            self.slider.value = value
        }
        coarseStepper.touchBeganCallback = {
            self.touchBeganCallback()
        }
        coarseStepper.touchEndedCallback = {
            self.touchEndedCallback()
        }
        fineStepper.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.coarseStepper.currentValue = value
            self.slider.value = value
        }
        fineStepper.touchBeganCallback = {
            self.touchBeganCallback()
        }
        fineStepper.touchEndedCallback = {
            self.touchEndedCallback()
        }
        slider.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.coarseStepper.currentValue = value
            self.fineStepper.currentValue = value
        }
        slider.touchBeganCallback = {
            self.touchBeganCallback()
        }
        slider.touchEndedCallback = {
            self.touchEndedCallback()
        }
        coarseStepper.backgroundColor = .clear
        fineStepper.backgroundColor = .clear
        coarseStepper.showsValue = false
        fineStepper.showsValue = false
        coarseStepper.buttonBorderWidth = buttonBorderWidth
        fineStepper.buttonBorderWidth = buttonBorderWidth

        valueLabel = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height * labelPercent))

        nameLabel = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height * labelPercent))
        buttons = UIStackView(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height * buttonPercent))
        setupFonts()
        addSubview(nameLabel)
        addSubview(valueLabel)
        addSubview(slider)
        addSubview(buttons)
        addToStackIfPossible(view: coarseStepper, stack: buttons)
        addToStackIfPossible(view: fineStepper, stack: buttons)
    }
    internal func setupFonts() {
        coarseStepper.labelFont = buttonLabelFont
        coarseStepper.buttonFont = buttonFont
        fineStepper.labelFont = buttonLabelFont
        fineStepper.buttonFont = buttonFont
        nameLabel.font = titleFont
        valueLabel.font = valueFont
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        genSubViews()
    }
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    private func genStackViews(rect: CGRect) {
        nameLabel.frame = CGRect(x: rect.origin.x + buttonBorderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.25)
        nameLabel.text = name
        nameLabel.textAlignment = .left

        valueLabel.frame = CGRect(x: rect.origin.x - buttonBorderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.25)
        valueLabel.textAlignment = .right

        slider.frame = CGRect(x: rect.origin.x, y: rect.origin.y + nameLabel.frame.height, width: rect.width, height: rect.height * 0.25)
        slider.range = minimum...maximum
        slider.value = currentValue

        buttons.frame = CGRect(x: rect.origin.x, y: rect.origin.y + slider.frame.height + valueLabel.frame.height, width: rect.width, height: rect.height * 0.5)
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 10
        buttons.layoutSubviews()
    }
    internal func addToStackIfPossible(view: UIView?, stack: UIStackView) {
        if view != nil {
            stack.addArrangedSubview(view!)
        }
    }
    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
    open var touchBeganCallback: () -> Void = { }
    open var touchEndedCallback: () -> Void = { }
    override open func layoutSubviews() {
        super.layoutSubviews()
        genStackViews(rect: bounds)
    }
}
