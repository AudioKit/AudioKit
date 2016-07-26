//
//  AKPropertySlider.swift
//  AudioKit for macOS
//
//  Created by Aurelius Prochazka on 7/26/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKPropertySlider: NSImageView {
    override public func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true
    }
    var callback: (Double)->()
    var initialValue: Double = 0
    public var currentValue: Double = 0 {
        didSet {
            update()
        }
    }
    var minimum: Double = 0
    var maximum: Double = 0
    var property: String = ""
    var format = ""
    var color = NSColor.redColor()
    
    public init(property: String,
         format: String,
         value: Double,
         minimum: Double = 0,
         maximum: Double = 1,
         color: NSColor = NSColor.redColor(),
         frame: CGRect,
         callback: (x: Double)->()) {
        self.currentValue = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color
        
        self.callback = callback
        super.init(frame: frame)
        
        imageScaling = .ScaleAxesIndependently
        update()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func mouseDown(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let center = convertPoint(loc, fromView: nil)
        currentValue = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        update()
        callback(currentValue)
    }
    override public func mouseDragged(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let center = convertPoint(loc, fromView: nil)
        currentValue = Double(center.x / bounds.width) * (maximum - minimum) + minimum
        update()
        callback(currentValue)
    }
    
    func update() {
        image = AKFlatSlider.imageOfFlatSlider(
            sliderColor: color,
            currentValue: CGFloat(currentValue),
            initialValue: CGFloat(initialValue),
            minimum: CGFloat(minimum),
            maximum: CGFloat(maximum),
            propertyName: property,
            currentValueText: String(format: format, currentValue)
        )
    }
}