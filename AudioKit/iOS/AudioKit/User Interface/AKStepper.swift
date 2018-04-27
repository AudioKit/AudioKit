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
open class AKStepper: UIView {

    @IBInspectable var text: String = "Stepper"
    var label: UILabel! //fixme
    var valueLabel: UILabel! //fixme
    var showsValue: Bool = true
    var plusButton: AKButton!
    var minusButton: AKButton?
    @IBInspectable var value: Double = 1.0
    @IBInspectable var increment: Double = 1.0
    @IBInspectable var minimum: Double = 0
    @IBInspectable var maximum: Double = 0
    open var callback: (Double)->Void = {val in
        print("callback: \(val)")
    }

    private var inverted: Bool {
        return maximum < minimum
    }
    private func doPlusAction(){
        value += min(increment, maximum - value)
        valueLabel.text = "\(value)"
        callback(value)
    }
    private func doMinusAction(){
        value -= min(increment, value - minimum)
        valueLabel.text = "\(value)"
        callback(value)
    }
    /// Initialize the stepper view
    public init(text: String, value: Double?,
                frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100),
                callback: @escaping (Double) -> Void) {
        self.callback = callback
        self.value = value!
        self.text = text
        super.init(frame: frame)
    }

    /// Initialize within Interface Builder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(minimum < maximum, "ARE YOU A WIZARD?")
    }

    /// Draw the stepper
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    
    private func genStackViews(rect: CGRect){
        plusButton = AKButton(title: "+", callback: {_ in
            self.doPlusAction()
        })
        minusButton = AKButton(title: "-", callback: {_ in
            self.doMinusAction()
        })
        let borderWidth = minusButton!.borderWidth
        label = UILabel(frame: CGRect(x: rect.origin.x + borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        label.text = text
        label.textAlignment = .left
        valueLabel = UILabel(frame: CGRect(x: rect.origin.x - borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        valueLabel.text = "\(value)"
        valueLabel.textAlignment = .right
        
        let buttons = UIStackView(frame: CGRect(x: rect.origin.x, y: rect.origin.y + label.frame.height, width: rect.width, height: rect.height * 0.7))
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 5
        
        addToStackIfPossible(view: minusButton, stack: buttons)
        addToStackIfPossible(view: plusButton, stack: buttons)
        
        self.addSubview(label)
        self.addSubview(buttons)
        if showsValue {
            self.addSubview(valueLabel)
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
    override open func layoutSubviews() {
        minusButton?.setNeedsDisplay()
        plusButton?.setNeedsDisplay()
    }
    private func addToStackIfPossible(view: UIView?, stack: UIStackView){
        if view != nil{
            stack.addArrangedSubview(view!)
        }
    }
}
