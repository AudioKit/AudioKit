//
//  AKTrigger.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/15/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** A triggering impulse function
*/
@objc class AKTrigger : AKParameter {
    
    // MARK: - Properties

    var trigger = false
    
    /** Computation of the next value */
    override func compute() {
        if trigger {
            leftOutput  = 1.0
            rightOutput = 1.0
            trigger = false
        } else {
            leftOutput  = 0.0
            rightOutput = 0.0
        }
    }
}