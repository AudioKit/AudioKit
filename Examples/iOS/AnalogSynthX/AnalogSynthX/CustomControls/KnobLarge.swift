//
//  KnobLarge.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol KnobLargeDelegate {
    func updateKnobValue(_ value: Double, tag: Int)
}

@IBDesignable
class KnobLarge: Knob {

    let baseImageName = "knob212_base"
    let indicatorImageName = "knob212_indicator"
    var delegate: KnobLargeDelegate?

    // Image Declarations
    var knob212Base = UIImage(named: baseImageName)
    var knob212Indicator = UIImage(named: indicatorImageName)

    override func draw(_ rect: CGRect) {
        drawKnobLarge(knobValue: knobValue)
    }

    // MARK: - Set Percentages
    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        super.setPercentagesWithTouchPoint(touchPoint)
        delegate?.updateKnobValue(value, tag: self.tag)
        setNeedsDisplay()
    }

    // MARK: - PaintCode generated code
    func drawKnobLarge(knobValue: CGFloat = 0.332) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let knobAngle: CGFloat = -240 * knobValue

        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 10, y: 10, width: 106, height: 106))
        context?.saveGState()
        picturePath.addClip()
        knob212Base!.draw(in: CGRect(x: 10, y: 10, width: knob212Base!.size.width, height: knob212Base!.size.height))
        context?.restoreGState()

        //// Picture 2 Drawing
        context?.saveGState()
        context?.translateBy(x: 63, y: 63)
        context?.rotate(by: -(knobAngle + 120) * CGFloat.pi / 180)

        let picture2Path = UIBezierPath(rect: CGRect(x: -53, y: -53, width: 106, height: 106))
        context?.saveGState()
        picture2Path.addClip()
        knob212Indicator!.draw(in: CGRect(x: -53,
                                          y: -53,
                                          width: knob212Indicator!.size.width,
                                          height: knob212Indicator!.size.height))
        context?.restoreGState()

        context?.restoreGState()
    }

    // MARK: - Allow knobs to appear in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        let bundle = Bundle(for: type(of: self))
        knob212Base = UIImage(named: baseImageName, in: bundle, compatibleWith: self.traitCollection)!
        knob212Indicator = UIImage(named: indicatorImageName, in: bundle, compatibleWith: self.traitCollection)!
    }

}
