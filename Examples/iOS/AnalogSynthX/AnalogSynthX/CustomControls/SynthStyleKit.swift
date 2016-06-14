//
//  SynthStyleKit.swift
//  AnalogSynthX
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.

import UIKit

public class SynthStyleKit: NSObject {

    //// Drawing Methods

    public class func drawKnobMedium(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Image Declarations
        let knob140_base = UIImage(named: "knob140_base.png")!
        let knob140_indicator = UIImage(named: "knob140_indicator.png")!

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// knob base Drawing
        let knobBasePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 70, height: 70))
        context?.saveGState()
        knobBasePath.addClip()
        knob140_base.draw(in: CGRect(x: 5, y: 5, width: knob140_base.size.width, height: knob140_base.size.height))
        context?.restoreGState()

        //// Indicator Drawing
        context?.saveGState()
        context?.translate(x: 40, y: 40)
        context?.rotate(byAngle: -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -35, y: -35, width: 70, height: 70))
        context?.saveGState()
        indicatorPath.addClip()
        knob140_indicator.draw(in: CGRect(x: -35, y: -35, width: knob140_indicator.size.width, height: knob140_indicator.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

    public class func drawKnobLarge(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Image Declarations
        let knob212_base = UIImage(named: "knob212_base.png")!
        let knob212_indicator = UIImage(named: "knob212_indicator.png")!

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 10, y: 10, width: 106, height: 106))
        context?.saveGState()
        picturePath.addClip()
        knob212_base.draw(in: CGRect(x: 10, y: 10, width: knob212_base.size.width, height: knob212_base.size.height))
        context?.restoreGState()

        //// Picture 2 Drawing
        context?.saveGState()
        context?.translate(x: 63, y: 63)
        context?.rotate(byAngle: -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let picture2Path = UIBezierPath(rect: CGRect(x: -53, y: -53, width: 106, height: 106))
        context?.saveGState()
        picture2Path.addClip()
        knob212_indicator.draw(in: CGRect(x: -53, y: -53, width: knob212_indicator.size.width, height: knob212_indicator.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

    public class func drawKnobSmall(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Image Declarations
        let knob120_base = UIImage(named: "knob120_base.png")!
        let knob120_indicator = UIImage(named: "knob120_indicator.png")!

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 60, height: 60))
        context?.saveGState()
        picturePath.addClip()
        knob120_base.draw(in: CGRect(x: 5, y: 5, width: knob120_base.size.width, height: knob120_base.size.height))
        context?.restoreGState()

        //// Indicator Drawing
        context?.saveGState()
        context?.translate(x: 35, y: 35)
        context?.rotate(byAngle: -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -30, y: -30, width: 60, height: 60))
        context?.saveGState()
        indicatorPath.addClip()
        knob120_indicator.draw(in: CGRect(x: -30, y: -30, width: knob120_indicator.size.width, height: knob120_indicator.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

}
