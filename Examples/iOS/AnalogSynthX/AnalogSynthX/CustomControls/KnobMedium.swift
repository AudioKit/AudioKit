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

    //// Image Declarations
    var knob140_base = UIImage(named: "knob140_base")
    var knob140_indicator = UIImage(named: "knob140_indicator")

    override func drawRect(rect: CGRect) {
        drawKnobMedium(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

    // MARK: - PaintCode generated code
    func drawKnobMedium(knobValue knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// knob base Drawing
        let knobBasePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 70, height: 70))
        CGContextSaveGState(context)
        knobBasePath.addClip()
        knob140_base!.drawInRect(CGRectMake(5, 5, knob140_base!.size.width, knob140_base!.size.height))
        CGContextRestoreGState(context)

        //// Indicator Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 40, 40)
        CGContextRotateCTM(context, -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -35, y: -35, width: 70, height: 70))
        CGContextSaveGState(context)
        indicatorPath.addClip()
        knob140_indicator!.drawInRect(CGRectMake(-35, -35, knob140_indicator!.size.width, knob140_indicator!.size.height))
        CGContextRestoreGState(context)

        CGContextRestoreGState(context)
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = NSBundle(forClass: self.dynamicType)
        knob140_base = UIImage(named: "knob140_base", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
        knob140_indicator = UIImage(named: "knob140_indicator", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
    }

}
