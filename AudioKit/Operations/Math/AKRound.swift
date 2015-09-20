//
//  AKRound.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Rounding of the input signal to the nearest integer.
*/
@objc class AKRound : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the rounded value
    - parameter input: Input signal.
    */
    init(_ sourceInput: AKParameter)
    {
        super.init()
        input = sourceInput
        dependencies = [input]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = round(input.leftOutput)
        rightOutput = round(input.rightOutput)
    }
}

/** Rounding helper function */
func round(parameter: AKParameter) -> AKRound {
    return AKRound(parameter)
}
