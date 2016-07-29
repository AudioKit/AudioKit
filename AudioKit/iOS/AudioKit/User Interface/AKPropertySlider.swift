//
//  AKPropertySlider.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public class AKPropertySlider: UIImageView {
    var callback: (Double)->()
    var initialValue: Double = 0
    public var value: Double = 0 {
        didSet {
            update()
        }
    }
    public var minimum: Double = 0
    public var maximum: Double = 0
    var property: String = ""
    var format = ""
    var color = AKColor.redColor()
    
    public init(property: String,
                format: String = "%0.3f",
                value: Double,
                minimum: Double = 0,
                maximum: Double = 1,
                color: AKColor = AKColor.redColor(),
                frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 60),
                callback: (x: Double)->()) {
        self.value = value
        self.initialValue = value
        self.minimum = minimum
        self.maximum = maximum
        self.property = property
        self.format = format
        self.color = color

        
        self.callback = callback
        super.init(frame: frame)
        self.userInteractionEnabled = true
        
//        imageScaling = .ScaleAxesIndependently
        update()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
            update()
            callback(value)

        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.locationInView(self)
            value = Double(touchLocation.x / bounds.width) * (maximum - minimum) + minimum
            if value > maximum { value = maximum }
            if value < minimum { value = minimum }
            update()
            callback(value)

        }
    }

    
    public func randomize() -> Double {
        value = random(minimum, maximum)
        update()
        return value
    }
    
    func update() {
        image = AKFlatSlider.imageOfFlatSlider(
            sliderColor: color,
            currentValue: CGFloat(value),
            initialValue: CGFloat(initialValue),
            minimum: CGFloat(minimum),
            maximum: CGFloat(maximum),
            propertyName: property,
            currentValueText: String(format: format, value)
        )
    }
}