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
    var plusButton: AKButton!
    var minusButton: AKButton!
    @IBInspectable var value: Double = 1.0
    @IBInspectable var increment: Double = 1.0
    @IBInspectable var minimum: Double = 0
    @IBInspectable var maximum: Double = 0
    open var callback: (Double)->Void = {val in
        print("callback: \(val)")
    }

    private var mainStack: UIStackView!
    
    private func doPlusAction(){
        print("up")
        value += increment
        callback(value)
    }
    private func doMinusAction(){
        print("dn")
        value -= increment
        callback(value)
    }
    /// Initialize the stepper view
    public init(text: String,
                      value: Double?,
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
    }

    /// Draw the stepper
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    
    private func genStackViews(rect: CGRect){
        mainStack = UIStackView(frame: rect)
        mainStack.axis = .vertical
        mainStack.distribution = .fillEqually
        mainStack.spacing = 10
        label = UILabel(frame: rect)
        label.text = text
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        
        let buttons = UIStackView(frame: rect)
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 5
        plusButton = AKButton(title: "+", callback: {_ in
            self.doPlusAction()
        })
        minusButton = AKButton(title: "-", callback: {_ in
            self.doMinusAction()
        })
        buttons.addArrangedSubview(minusButton)
        buttons.addArrangedSubview(plusButton)
        
        mainStack.addArrangedSubview(label)
        mainStack.addArrangedSubview(buttons)
        self.addSubview(mainStack)
        buttons.layoutIfNeeded()
    }
    
    /// Require constraint-based layout
    open class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        clipsToBounds = true
    }
}
