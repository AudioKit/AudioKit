//
//  AKParameterSlider.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/13/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import Cocoa

class AKParameterSlider : NSSlider {

    var parameter: AKParameter? {
        didSet {
            parameter?.addObserver(self,
                forKeyPath: "leftOutput",
                options: NSKeyValueObservingOptions.New,
                context: &MyObservationContext
            )
            self.action = "changed"
            self.target = self
            self.setNeedsDisplay()
        }
    }
    
    var minimum: Float? {
        didSet {
            self.minValue = Double(minimum!)
            self.setNeedsDisplay()
        }
    }

    var maximum: Float? {
        didSet {
            self.maxValue = Double(maximum!)
            self.setNeedsDisplay()
        }
    }
    
    func changed() {
        if let param = parameter {
            param.value = self.floatValue
        }
    }

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