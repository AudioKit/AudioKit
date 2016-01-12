//
//  KnobMedium.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/18/16.
//  Copyright © 2016 CodeMarket. All rights reserved.
//

import UIKit

protocol KnobMediumDelegate {
    func updateKnobValue(value: Double, tag: Int)
}

@IBDesignable
class KnobMedium: Knob {
    
    var delegate: KnobMediumDelegate?
    
    override func drawRect(rect: CGRect) {
        SynthStyleKit.drawKnobMedium(knobValue: knobValue)
    }
    
    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        updateKnob()
    }
    
    override func setMaximumValue() {
        super.setMaximumValue()
        updateKnob()
    }
    
    override func setMinimumValue() {
        super.setMinimumValue()
        updateKnob()
    }
    
    func updateKnob() {
        delegate?.updateKnobValue(Double(knobValue), tag: self.tag)
        setNeedsDisplay()
    }
}

