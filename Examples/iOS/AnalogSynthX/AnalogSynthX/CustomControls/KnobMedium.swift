//
//  KnobMedium.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/18/16.
//  Copyright © 2016 AudioKit. All rights reserved.
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
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

}
