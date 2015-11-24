//
//  AKPlaygroundHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/23/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func newSlider(width: Int) -> NSSlider {
    let padding = 30
    let sliderHeight = 20
    return NSSlider(frame: NSRect(x: padding, y: 0, width: width, height: sliderHeight))
}

func newTextField(width: Int) -> NSTextField {
    let padding = 30
    let sliderHeight = 20
    return NSTextField(frame: NSRect(x: padding, y: 0, width: width, height: sliderHeight))
}

func makeTextField(
    textField: NSTextField,
    view: NSView,
    below: AnyObject,
    distance: Int,
    stringValue: String) {
        
        let sliderHeight = 20
        
        textField.stringValue = stringValue
        textField.editable = false
        textField.drawsBackground = false
        textField.bezeled = false
        textField.frame.origin.y = below.frame.origin.y - CGFloat(distance * sliderHeight)
        view.addSubview(textField)
}

func makeSlider(
    slider: NSSlider,
    view: NSView,
    below: AnyObject,
    distance: Int,
    target: AnyObject,
    action: String,
    currentValue: Float,
    minimumValue: Float,
    maximumValue: Float) {
        
        let sliderHeight = 20
        
        slider.target = target
        slider.action = Selector(action)
        slider.minValue = Double(minimumValue)
        slider.maxValue = Double(maximumValue)
        slider.floatValue = currentValue
        slider.frame.origin.y = below.frame.origin.y - CGFloat(distance * sliderHeight)
        view.addSubview(slider)
        
}
