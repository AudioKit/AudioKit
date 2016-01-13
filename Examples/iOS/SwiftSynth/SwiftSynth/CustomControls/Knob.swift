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
    
    // Knob properties
    var knobValue: CGFloat = 0.5 {
        didSet {
            if knobValue > 1 {
                knobValue = 1
            }
            if knobValue < 0 {
                knobValue = 0
            }
        }
    }
    let knobSensitivity: CGFloat = 0.005 // Value change per pt
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        
        // Knobs assume up or right is increasing, and down or left is decreasing
        
        let horizontalChange = (touchPoint.x - lastX) * knobSensitivity
        knobValue += horizontalChange
        
        let verticalChange = (touchPoint.y - lastY) * knobSensitivity
        knobValue -= verticalChange

        lastX = touchPoint.x
        lastY = touchPoint.y
    }
    
    // Scale any range to 0.0-1.0 for Knob position
    func scaleForKnobValue(value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        return abs((value - rangeMin) / (rangeMin - rangeMax))
    }

}