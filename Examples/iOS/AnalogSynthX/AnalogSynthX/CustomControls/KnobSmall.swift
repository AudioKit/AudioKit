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
    var knob120_base = UIImage(named: "knob120_base")
    var knob120_indicator = UIImage(named: "knob120_indicator")


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
        knob120_base!.draw(in: CGRect(x: 5, y: 5, width: knob120_base!.size.width, height: knob120_base!.size.height))
        context?.restoreGState()

        //// Indicator Drawing
        context?.saveGState()
        context?.translateBy(x: 35, y: 35)
        context?.rotate(by: -(knobAngle + 120) * CGFloat(M_PI) / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -30, y: -30, width: 60, height: 60))
        context?.saveGState()
        indicatorPath.addClip()
        knob120_indicator!.draw(in: CGRect(x: -30, y: -30, width: knob120_indicator!.size.width, height: knob120_indicator!.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = Bundle(for: type(of: self))
        knob120_base = UIImage(named: "knob120_base", in: bundle, compatibleWith: self.traitCollection)!
        knob120_indicator = UIImage(named: "knob120_indicator", in: bundle, compatibleWith: self.traitCollection)!
    }

}
