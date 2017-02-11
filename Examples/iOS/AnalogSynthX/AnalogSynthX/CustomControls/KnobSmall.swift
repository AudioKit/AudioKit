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

    //// Image Declarations
    var knob120Base = UIImage(named: "knob120_base")
    var knob120Indicator = UIImage(named: "knob120_indicator")

    override func draw(_ rect: CGRect) {
        drawKnobSmall(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

    // MARK: - PaintCode generated code
    func drawKnobSmall(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 60, height: 60))
        context?.saveGState()
        picturePath.addClip()
        knob120Base!.draw(in: CGRect(x: 5,
                                     y: 5,
                                     width: knob120Base!.size.width,
                                     height: knob120Base!.size.height))
        context?.restoreGState()

        //// Indicator Drawing
        context?.saveGState()
        context?.translateBy(x: 35, y: 35)
        context?.rotate(by: -(knobAngle + 120) * CGFloat.pi / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -30, y: -30, width: 60, height: 60))
        context?.saveGState()
        indicatorPath.addClip()
        knob120Indicator!.draw(in: CGRect(x: -30,
                                          y: -30,
                                          width: knob120Indicator!.size.width,
                                          height: knob120Indicator!.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = Bundle(for: type(of: self))
        knob120Base = UIImage(named: "knob120_base", in: bundle, compatibleWith: self.traitCollection)!
        knob120Indicator = UIImage(named: "knob120_indicator", in: bundle, compatibleWith: self.traitCollection)!
    }

}
