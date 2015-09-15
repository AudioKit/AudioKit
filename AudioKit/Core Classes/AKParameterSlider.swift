//
//  AKParameterSlider.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/13/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import Cocoa

/** A subclass of sliders to control AKParameter values */
class AKParameterSlider : NSSlider {

    /** The AKParameter to control the value of */
    var parameter: AKParameter? {
        didSet {
            parameter?.addObserver(self,
                forKeyPath: "leftOutput",
                options: NSKeyValueObservingOptions.New,
                context: &AKObservationContext
            )
            self.action = "changed"
            self.target = self
            self.setNeedsDisplay()
        }
    }
    
    /** Minimum value for the slider */
    var minimum: Float? {
        didSet {
            self.minValue = Double(minimum!)
            self.setNeedsDisplay()
        }
    }

    /** Maximum value for the slider */
    var maximum: Float? {
        didSet {
            self.maxValue = Double(maximum!)
            self.setNeedsDisplay()
        }
    }
 
    /** Update the parameter's value when the slider value has changed */
    internal func changed() {
        if let param = parameter {
            param.value = self.floatValue
        }
    }

    /** Observe the parameter value and update the slider accordingly */
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "leftOutput" {
            if let param = parameter {
                self.floatValue = param.leftOutput
            }
        }
    }
    

    
    
}