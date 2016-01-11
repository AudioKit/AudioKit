//
//  Knob2View.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 CodeMarket. All rights reserved.
//

import UIKit

protocol KnobSmallDelegate {
    func updateKnobValue(value: Float, tag: Int)
}

@IBDesignable
class KnobSmall: Knob {
    
    var delegate: KnobSmallDelegate?

    override func drawRect(rect: CGRect) {
        SynthStyleKit.drawKnobSmall(knobValue: knobValue)
    }
    
    // MARK: - Update from ViewController Slider
    func updatePressure(newPressure: Float) {
        knobValue = CGFloat(newPressure)
        setNeedsDisplay()
    }
    
    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        
        delegate?.updateKnobValue(Float(knobValue), tag: self.tag)
        setNeedsDisplay()
    }
}

