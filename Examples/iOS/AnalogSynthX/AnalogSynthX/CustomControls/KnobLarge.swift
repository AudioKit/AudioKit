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

    // Image Declarations
    var knob212_base = UIImage(named: "knob212_base")
    var knob212_indicator = UIImage(named: "knob212_indicator")

    override func drawRect(rect: CGRect) {
        drawKnobLarge(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

    // MARK: - PaintCode generated code
    func drawKnobLarge(knobValue knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 10, y: 10, width: 106, height: 106))
        CGContextSaveGState(context)
        picturePath.addClip()
        knob212_base!.drawInRect(CGRectMake(10, 10, knob212_base!.size.width, knob212_base!.size.height))
        CGContextRestoreGState(context)

        //// Picture 2 Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 63, 63)
        CGContextRotateCTM(context, -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let picture2Path = UIBezierPath(rect: CGRect(x: -53, y: -53, width: 106, height: 106))
        CGContextSaveGState(context)
        picture2Path.addClip()
        knob212_indicator!.drawInRect(CGRectMake(-53, -53, knob212_indicator!.size.width, knob212_indicator!.size.height))
        CGContextRestoreGState(context)

        CGContextRestoreGState(context)
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = NSBundle(forClass: self.dynamicType)
        knob212_base = UIImage(named: "knob212_base", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
        knob212_indicator = UIImage(named: "knob212_indicator", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
    }

}
