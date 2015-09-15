//
//  AKSum.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func + (left: AKParameter, right: AKParameter) -> AKSum {
    return AKSum(input: left, plus: right)
}

/** Sum of two input signals
*/
@objc class AKSum : AKParameter {
    
    // MARK: - Properties
    
    private var first  = AKParameter()
    private var second = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the sum
    - parameter input: The first input.
    - parameter plus: The second input.
    */
    init(input firstInput: AKParameter, plus secondInput: AKParameter)
    {
        super.init()
        first = firstInput
        second = secondInput
        dependencies = [first, second]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = first.leftOutput  + second.leftOutput
        rightOutput = first.rightOutput + second.rightOutput
    }
    
}
