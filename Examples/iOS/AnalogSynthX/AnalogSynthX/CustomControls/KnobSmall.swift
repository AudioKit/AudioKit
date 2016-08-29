//
//  Knob2View.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KnobSmallDelegate {
    func updateKnobValue(value: Double, tag: Int)
}

@IBDesignable
class KnobSmall: Knob {

    var delegate: KnobSmallDelegate?
    
    //// Image Declarations
    var knob120_base = UIImage(named: "knob120_base")
    var knob120_indicator = UIImage(named: "knob120_indicator")


    override func drawRect(rect: CGRect) {
        drawKnobSmall(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }
    
    // MARK: - PaintCode generated code
    func drawKnobSmall(knobValue knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue
        
        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRectMake(5, 5, 60, 60))
        CGContextSaveGState(context)
        picturePath.addClip()
        knob120_base!.drawInRect(CGRectMake(5, 5, knob120_base!.size.width, knob120_base!.size.height))
        CGContextRestoreGState(context)
        
        //// Indicator Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 35, 35)
        CGContextRotateCTM(context, -(knobAngle + 120) * CGFloat(M_PI) / 180)
        
        let indicatorPath = UIBezierPath(rect: CGRectMake(-30, -30, 60, 60))
        CGContextSaveGState(context)
        indicatorPath.addClip()
        knob120_indicator!.drawInRect(CGRectMake(-30, -30, knob120_indicator!.size.width, knob120_indicator!.size.height))
        CGContextRestoreGState(context)
        
        CGContextRestoreGState(context)
    }
    
    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        knob120_base = UIImage(named: "knob120_base", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
        knob120_indicator = UIImage(named: "knob120_indicator", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
    }

}
