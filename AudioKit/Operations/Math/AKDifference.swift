//
//  AKDifference.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func - (left: AKParameter, right: AKParameter) -> AKDifference {
    return AKDifference(input: left, minus: right)
}

/** Difference of two inputs signals
*/
@objc class AKDifference : AKParameter {
    
    // MARK: - Properties
    
    private var minuend    = AKParameter()
    private var subtrahend = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the absoute value
    - parameter input: Input audio signal.
    */
    init(input minuendInput: AKParameter, minus subtrahendInput: AKParameter)
    {
        super.init()
        minuend = minuendInput
        subtrahend = subtrahendInput
        dependencies = [minuend, subtrahend]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = minuend.leftOutput  - subtrahend.leftOutput
        rightOutput = minuend.rightOutput - subtrahend.rightOutput
    }
    
}
