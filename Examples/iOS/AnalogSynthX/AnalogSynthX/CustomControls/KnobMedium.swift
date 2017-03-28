//
//  KnobMedium.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/18/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KnobMediumDelegate: class {
    func updateKnobValue(_ value: Double, tag: Int)
}

@IBDesignable
class KnobMedium: Knob {

    weak var delegate: KnobMediumDelegate?

    //// Image Declarations
    var knob140Base = UIImage(named: "knob140_base")
    var knob140Indicator = UIImage(named: "knob140_indicator")

    override func draw(_ rect: CGRect) {
        drawKnobMedium(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

    // MARK: - PaintCode generated code
    func drawKnobMedium(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// knob base Drawing
        let knobBasePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 70, height: 70))
        context?.saveGState()
        knobBasePath.addClip()
        knob140Base!.draw(in: CGRect(x: 5,
                                     y: 5,
                                     width: knob140Base!.size.width,
                                     height: knob140Base!.size.height))
        context?.restoreGState()

        //// Indicator Drawing
        context?.saveGState()
        context?.translateBy(x: 40, y: 40)
        context?.rotate(by: -(knobAngle + 120) * CGFloat.pi / 180)

        let indicatorPath = UIBezierPath(rect: CGRect(x: -35, y: -35, width: 70, height: 70))
        context?.saveGState()
        indicatorPath.addClip()
        knob140Indicator!.draw(in: CGRect(x: -35,
                                          y: -35,
                                          width: knob140Indicator!.size.width,
                                          height: knob140Indicator!.size.height))
        context?.restoreGState()
        context?.restoreGState()
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = Bundle(for: type(of: self))
        knob140Base = UIImage(named: "knob140_base", in: bundle, compatibleWith: self.traitCollection)!
        knob140Indicator = UIImage(named: "knob140_indicator", in: bundle, compatibleWith: self.traitCollection)!
    }

}
