//
//  AKAbsoluteValue.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Absolute value helper function */
func abs(parameter: AKParameter) -> AKAbsoluteValue {
    return AKAbsoluteValue(input: parameter)
}

/** Absolute value of the input signal.
*/
@objc class AKAbsoluteValue : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the absoute value
    - parameter input: Input signal.
    */
    init(input sourceInput: AKParameter)
    {
        super.init()
        input = sourceInput
        dependencies = [input]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = abs(input.leftOutput)
        rightOutput = abs(input.rightOutput)
    }
    
}
