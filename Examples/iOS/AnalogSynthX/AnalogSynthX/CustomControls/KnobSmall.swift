//
//  Knob2View.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KnobSmallDelegate {
    func updateKnobValue(_ value: Double, tag: Int)
}

@IBDesignable
class KnobSmall: Knob {

    var delegate: KnobSmallDelegate?

    override func draw(_ rect: CGRect) {
        SynthStyleKit.drawKnobSmall(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

}
