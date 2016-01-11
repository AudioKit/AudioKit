//
//  Knob.swift
//  Synth UI Spike
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
    var knobValue: CGFloat = 0.5
    var horizontalPercentage: CGFloat = 0.0
    var verticalPercentage: CGFloat = 0.0
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    // Check to see if touchpoint is within custom view
    func checkKnobBounds(touchPoint: CGPoint) {
        if touchPoint.x > 0 && touchPoint.x < self.bounds.size.width &&
            touchPoint.y > 0 && touchPoint.y < self.bounds.size.height {
            setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    func setPercentagesWithTouchPoint(touchPoint: CGPoint) {
        horizontalPercentage = touchPoint.x / self.bounds.size.width
        verticalPercentage = touchPoint.y / self.bounds.size.height
        verticalPercentage = 1 - verticalPercentage
        
        if directionHorizontal {
            knobValue = horizontalPercentage
        } else {
            knobValue = verticalPercentage
        }

    }
    
    // Scale any range to 0.0-1.0 for Knob position
    func scaleForKnobValue(value: Float, rangeMin: Float, rangeMax: Float) -> Float {
        return abs((value - rangeMin) / (rangeMin - rangeMax))
    }

}