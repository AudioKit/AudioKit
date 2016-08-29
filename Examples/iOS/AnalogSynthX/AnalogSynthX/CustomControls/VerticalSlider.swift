//
//  VerticalSlider.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/11/16.
//  Copyright (c) 2016 AudioKit. All rights reserved.

// Slider code adapted from:
// http://www.totem.training/swift-ios-tips-tricks-tutorials-blog/paint-code-and-live-views

import UIKit

protocol VerticalSliderDelegate {
    func sliderValueDidChange(value: Double, tag: Int)
}

@IBDesignable
class VerticalSlider: UIControl {

    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 1.0
    var currentValue: CGFloat = 0.45 {
        didSet {
            if currentValue < 0 {
                currentValue = 0
            }
            if currentValue > maxValue {
                currentValue = maxValue
            }
            self.sliderValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
            setupView()
        }
    }

    let knobSize = CGSize(width: 43, height: 31)
    let barMargin: CGFloat = 20.0
    var knobRect: CGRect!
    var barLength: CGFloat = 164.0
    var isSliding = false
    var sliderValue: CGFloat = 0.5
    var delegate: VerticalSliderDelegate?

    //// Image Declarations
    var slider_top = UIImage(named: "slider_top.png")
    var slider_track = UIImage(named: "slider_track.png")


    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .Redraw
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.userInteractionEnabled = true
        contentMode = .Redraw
    }

    class override func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}

// MARK: - Lifecycle
extension VerticalSlider {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {

        knobRect = CGRect(x: 0, y: convertValueToY(currentValue) - (knobSize.height / 2), width: knobSize.width, height: knobSize.height)
        barLength = bounds.height - (barMargin * 2)

        let bundle = NSBundle(forClass: self.dynamicType)
        slider_top =  UIImage(named: "slider_top", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
        slider_track =  UIImage(named: "slider_track", inBundle: bundle, compatibleWithTraitCollection: self.traitCollection)!
    }

    override func drawRect(rect: CGRect) {
        drawVerticalSlider(controlFrame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), knobRect: knobRect)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

// MARK: - Helpers
extension VerticalSlider {
    func convertYToValue(y: CGFloat) -> CGFloat {
        let offsetY = bounds.height - barMargin - y
        let value = (offsetY * maxValue) / barLength
        return value
    }
    func convertValueToY(value: CGFloat) -> CGFloat {
        let rawY = (value * barLength) / maxValue
        let offsetY = bounds.height - barMargin - rawY
        return offsetY
    }
}

// MARK: - Control Touch Handling
extension VerticalSlider {
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if CGRectContainsPoint(knobRect, touch.locationInView(self)) {
            isSliding = true
        }
        return true
    }

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let rawY = touch.locationInView(self).y

        if isSliding {
            let value = convertYToValue(rawY)

            if value != minValue || value != maxValue {
                currentValue = value
                delegate?.sliderValueDidChange(Double(currentValue), tag: self.tag)
                setNeedsDisplay()
            }
        }
        return true
    }

    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        isSliding = false
    }

    func drawVerticalSlider(controlFrame controlFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 216), knobRect: CGRect = CGRect(x: 0, y: 89, width: 36, height: 32)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Background Drawing
        let backgroundRect = CGRectMake(controlFrame.minX + 2, controlFrame.minY + 10, 38, 144)
        let backgroundPath = UIBezierPath(rect: backgroundRect)
        CGContextSaveGState(context)
        backgroundPath.addClip()
        slider_track!.drawInRect(CGRectMake(floor(backgroundRect.minX + 0.5), floor(backgroundRect.minY + 0.5), slider_track!.size.width, slider_track!.size.height))
        CGContextRestoreGState(context)


        //// Slider Top Drawing
        let sliderTopRect = CGRectMake(knobRect.origin.x, knobRect.origin.y, knobRect.size.width, knobRect.size.height)
        let sliderTopPath = UIBezierPath(rect: sliderTopRect)
        CGContextSaveGState(context)
        sliderTopPath.addClip()
        slider_top!.drawInRect(CGRectMake(floor(sliderTopRect.minX + 0.5), floor(sliderTopRect.minY + 0.5), slider_top!.size.width, slider_top!.size.height))
        CGContextRestoreGState(context)
    }
}
