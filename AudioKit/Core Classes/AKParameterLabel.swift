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
var MyObservationContext = KVOContext()

class AKParameterLabel : NSTextField {
 
    var format = "%0.2f"
    
    var parameter: AKParameter? {
        didSet {
            parameter?.addObserver(self,
                forKeyPath: "leftOutput",
                options: NSKeyValueObservingOptions.New,
                context: &MyObservationContext
            )
            self.setNeedsDisplay()
        }
    }
    
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        self.setNeedsDisplay()
    }
    
    override func setNeedsDisplay() {
        if let param = parameter {
            let str = String(format: format, param.leftOutput)
            self.stringValue = str
            super.setNeedsDisplay()
        }
    }
    
    
}