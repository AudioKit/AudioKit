//
//  AKTweaker.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

@IBDesignable open class AKTweaker : UIView {
    
    @IBInspectable open var name: String = "Tweaker"
    var coarseStepper : AKStepper!
    var fineStepper : AKStepper!
    var nudger: AKNugder!
    var nameLabel: UILabel!
    var valueLabel: UILabel?
    public var currentValue: Double = 1.0 {
        didSet{
            DispatchQueue.main.async {
                self.valueLabel?.text = String(format: "%.3f", self.currentValue)
            }
        }
    }
    public var callback: (Double) -> Void = {val in
        print(val)
    }
    public func setStable(value: Double){
        nudger.setStable(value: value)
        coarseStepper.currentValue = value
        fineStepper.currentValue = value
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        genSubViews()
    }
    private func genSubViews(){
        coarseStepper = AKStepper(text: "Coarse", value: 1.0, minimum: -2.0, maximum: 2.0,
                                  increment: 0.1, showsValue: false, callback: {_ in })
        fineStepper = AKStepper(text: "Fine", value: 1.0, minimum: -2.0, maximum: 2.0,
                                increment: 0.01, showsValue: false, callback: {_ in })
        nudger = AKNugder(text: "Nudge", value: 1.0, minimum: -2.0, maximum: 2.0,
                          increment: 0.0666, showsValue: false, callback: {_ in })
        coarseStepper.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.fineStepper.currentValue = value
            self.nudger.setStable(value: value)
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
            self.nudger.setStable(value: value)
        }
        fineStepper.touchBeganCallback = {
            self.touchBeganCallback()
        }
        fineStepper.touchEndedCallback = {
            self.touchEndedCallback()
        }
        nudger.linear = false
        nudger.callback = {value in
            self.callback(value)
            self.currentValue = value
        }
        nudger.touchBeganCallback = {
            self.touchBeganCallback()
        }
        nudger.touchEndedCallback = {
            self.touchEndedCallback()
        }
        coarseStepper.backgroundColor = .clear
        fineStepper.backgroundColor = .clear
        nudger.backgroundColor = .clear
        coarseStepper.showsValue = false
        fineStepper.showsValue = false
        nudger.showsValue = false
        
        valueLabel = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height * 0.3))
        
        nameLabel = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height * 0.3))
        self.addSubview(nameLabel)
        self.addSubview(valueLabel!)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        genSubViews()
    }
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        genStackViews(rect: rect)
    }
    private func genStackViews(rect: CGRect){
        let borderWidth = fineStepper.plusButton.borderWidth
        nameLabel.frame = CGRect(x: rect.origin.x + borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3)
        nameLabel.text = name
        nameLabel.textAlignment = .left
        
        valueLabel?.frame = CGRect(x: rect.origin.x - borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3)
        valueLabel?.textAlignment = .right
        
        let buttons = UIStackView(frame: CGRect(x: rect.origin.x, y: rect.origin.y + nameLabel.frame.height, width: rect.width, height: rect.height * 0.7))
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 10
        
        addToStackIfPossible(view: coarseStepper, stack: buttons)
        addToStackIfPossible(view: fineStepper, stack: buttons)
        addToStackIfPossible(view: nudger, stack: buttons)
        
        self.addSubview(buttons)
    }
    private func addToStackIfPossible(view: UIView?, stack: UIStackView){
        if view != nil{
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
}
