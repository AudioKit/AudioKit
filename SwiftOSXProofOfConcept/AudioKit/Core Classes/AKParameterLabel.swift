//
//  AKParameterLabel.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/13/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import Cocoa

typealias KVOContext = UInt8
/** A key-value observation context to use application-wide */
var AKObservationContext = KVOContext()

/** A subclass of text fields / labels to display AKParameter values */
class AKParameterLabel : NSTextField {
 
    /** Format string for the parameter label */
    var format = "%0.2f"
    
    /** The AKParameter to display the value of */
    var parameter: AKParameter? {
        didSet {
            parameter?.addObserver(self,
                forKeyPath: "leftOutput",
                options: NSKeyValueObservingOptions.New,
                context: &AKObservationContext
            )
            self.setNeedsDisplay()
        }
    }
    
    /** Observe the parameter value */
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        if keyPath! == "leftOutput" {
            self.setNeedsDisplay()
        }
    }
    
    /** Update the paramer label string */
    override func setNeedsDisplay() {
        if let param = parameter {
            let str = String(format: format, param.leftOutput)
            self.stringValue = str
            super.setNeedsDisplay()
        }
    }
    
    
}