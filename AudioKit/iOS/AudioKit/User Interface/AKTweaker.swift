//
//  AKTweaker.swift
//  AudioKit
//
//  Created by Jeff Cooper on 5/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

open class AKTweaker : UIView {
    
    @IBInspectable open var name: String = "Speed"
    var coarseStepper : AKStepper!
    var fineStepper : AKStepper!
    var nudger: AKNugder!
    var nameLabel: UILabel!
    var valueLabel: UILabel!
    public var currentValue: Double = 1.0 {
        didSet{
            DispatchQueue.main.async {
                self.valueLabel.text = String(format: "%.3f", self.currentValue)
            }
        }
    }
    public var callback: (Double) -> Void = {val in
        print(val)
    }
    public func setStable(value: Double){
        nudger.setStable(value: value)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        genSubViews()
    }
    private func genSubViews(){
        coarseStepper = AKStepper(text: "Coarse", value: 1.0, minimum: -2.0, maximum: 2.0,
                                  increment: 0.1, callback: {_ in })
        fineStepper = AKStepper(text: "Fine", value: 1.0, minimum: -2.0, maximum: 2.0,
                                increment: 0.01, callback: {_ in })
        nudger = AKNugder(text: "Nudge", value: 1.0, minimum: -2.0, maximum: 2.0,
                          increment: 0.0666, callback: {_ in })
        coarseStepper.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.fineStepper.currentValue = value
            self.nudger.setStable(value: value)
        }
        fineStepper.callback = { value in
            self.callback(value)
            self.currentValue = value
            self.coarseStepper.currentValue = value
            self.nudger.setStable(value: value)
        }
        nudger.linear = false
        nudger.callback = {value in
            self.callback(value)
            self.currentValue = value
        }
        coarseStepper.backgroundColor = .clear
        fineStepper.backgroundColor = .clear
        nudger.backgroundColor = .clear
        coarseStepper.showsValue = false
        fineStepper.showsValue = false
        nudger.showsValue = false
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
        nameLabel = UILabel(frame: CGRect(x: rect.origin.x + borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        nameLabel.text = name
        nameLabel.textAlignment = .left
        
        valueLabel = UILabel(frame: CGRect(x: rect.origin.x - borderWidth, y: rect.origin.y, width: rect.width, height: rect.height * 0.3))
        valueLabel.text = "\(currentValue)"
        valueLabel.textAlignment = .right
        
        let buttons = UIStackView(frame: CGRect(x: rect.origin.x, y: rect.origin.y + nameLabel.frame.height, width: rect.width, height: rect.height * 0.7))
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 5
        
        addToStackIfPossible(view: coarseStepper, stack: buttons)
        addToStackIfPossible(view: fineStepper, stack: buttons)
        addToStackIfPossible(view: nudger, stack: buttons)
        
        self.addSubview(nameLabel)
        self.addSubview(valueLabel)
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
}
