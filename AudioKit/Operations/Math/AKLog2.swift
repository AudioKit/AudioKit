//
//  AKLog2.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Log base 2 of the input signal.
*/
@objc class AKLog2 : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the log2
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
        leftOutput  = log2(input.leftOutput)
        rightOutput = log2(input.rightOutput)
    }
}

/** Log base 2 helper function */
func log2(parameter: AKParameter) -> AKLog2 {
    return AKLog2(input: parameter)
}
