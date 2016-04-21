//
//  KnobLarge.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KnobLargeDelegate {
    func updateKnobValue(value: Double, tag: Int)
}

@IBDesignable
class KnobLarge: Knob {

    var delegate: KnobLargeDelegate?

    override func drawRect(rect: CGRect) {
        SynthStyleKit.drawKnobLarge(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

}
