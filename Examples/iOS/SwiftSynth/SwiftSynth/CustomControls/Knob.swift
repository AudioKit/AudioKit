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
    
    // Allow knobs to be controlled left-to-right or up-and-down
    let directionHorizontal = false
    
    // Knob properties
    var knobValue: CGFloat = 0.5 {
        didSet {
            horizontalPercentage = knobValue
            verticalPercentage = knobValue
        }
    }
    let knobSensitivity: CGFloat = 0.005
    var horizontalPercentage: CGFloat = 0.0
    var verticalPercentage: CGFloat = 0.0
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        let horizontalChange = (touchPoint.x - lastX) * knobSensitivity
        horizontalPercentage += horizontalChange
        horizontalPercentage = max(0, min(horizontalPercentage, 1))
        
        let verticalChange = (touchPoint.y - lastY) * knobSensitivity
        verticalPercentage -= verticalChange
        verticalPercentage = max(0, min(verticalPercentage, 1))
        
        if directionHorizontal {
            knobValue = horizontalPercentage
        } else {
            knobValue = verticalPercentage
        }
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
    
    func setMaximumValue() {
        knobValue = 1.0
        verticalPercentage = 0
    }
    
    func setMinimumValue() {
        knobValue = 0.0
        verticalPercentage = 1.0
    }
    
    // Scale any range to 0.0-1.0 for Knob position
    func scaleForKnobValue(value: Double, rangeMin: Double, rangeMax: Double) -> Double {
        return abs((value - rangeMin) / (rangeMin - rangeMax))
    }

}