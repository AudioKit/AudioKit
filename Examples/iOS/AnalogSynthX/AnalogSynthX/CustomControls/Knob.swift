//
//  Knob.swift
//  Swift Synth
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

@IBDesignable
class Knob: UIView {

    var minimum = 0.0 {
        didSet {
            self.knobValue = CGFloat((value - minimum) / (maximum - minimum))
        }
    }
    var maximum = 1.0 {
        didSet {
            self.knobValue = CGFloat((value - minimum) / (maximum - minimum))
        }
    }

    var value: Double = 0 {
        didSet {
            if value > maximum {
                value = maximum
            }
            if value < minimum {
                value = minimum
            }
            self.knobValue = CGFloat((value - minimum) / (maximum - minimum))
        }
    }

    // Knob properties
    var knobValue: CGFloat = 0.5
    var knobSensitivity = 0.005
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .Redraw
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.userInteractionEnabled = true
        contentMode = .Redraw
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        contentMode = .ScaleAspectFill
        clipsToBounds = true
    }
    
    class override func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    // Helper
    func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing

        let horizontalChange = Double(touchPoint.x - lastX) * knobSensitivity
        value += horizontalChange * (maximum - minimum)

        let verticalChange = Double(touchPoint.y - lastY) * knobSensitivity
        value -= verticalChange * (maximum - minimum)

        lastX = touchPoint.x
        lastY = touchPoint.y
    }
    
    
}
