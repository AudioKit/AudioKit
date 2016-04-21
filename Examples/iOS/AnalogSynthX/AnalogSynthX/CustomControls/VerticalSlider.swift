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
    }

    override func drawRect(rect: CGRect) {
        VerticalSliderStyles.drawVerticalSlider(controlFrame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), knobRect: knobRect)
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
}
