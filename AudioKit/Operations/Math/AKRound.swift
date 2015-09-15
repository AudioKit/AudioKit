//
//  AKRound.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func round(parameter: AKParameter) -> AKRound {
    return AKRound(input: parameter)
}

/** Round of the input signal.
*/
@objc class AKRound : AKParameter {
    
    // MARK: - Properties
    
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the rounded value
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
        leftOutput  = round(input.leftOutput)
        rightOutput = round(input.rightOutput)
    }
    
}

