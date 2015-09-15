//
//  AKLog10.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func log10(parameter: AKParameter) -> AKLog10 {
    return AKLog10(input: parameter)
}

/** Log10 of the input signal.
*/
@objc class AKLog10 : AKParameter {
    
    // MARK: - Properties
    
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the log10
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
        leftOutput  = log10(input.leftOutput)
        rightOutput = log10(input.rightOutput)
    }
    
}