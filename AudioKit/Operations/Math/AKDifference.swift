//
//  AKDifference.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Difference of two inputs signals
*/
@objc class AKDifference : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var minuend    = AKParameter()
    /** Input to the mathematical function */
    private var subtrahend = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the difference
    - parameter input: The input to be subtracted from.
    - parameter minus: The input that will be subtracted.
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

/** Subtraction helper function */
func - (left: AKParameter, right: AKParameter) -> AKDifference {
    return AKDifference(input: left, minus: right)
}

/** Subtraction helper function */
func - (left: AKParameter, right: Float) -> AKDifference {
    return AKDifference(input: left, minus: akp(right))
}

/** Subtraction helper function */
func - (left: Float, right: AKParameter) -> AKDifference {
    return AKDifference(input: akp(left), minus: right)
}

/** Subtraction helper function */
func - (left: AKParameter, right: Int) -> AKDifference {
    return AKDifference(input: left, minus: akpi(right))
}

/** Subtraction helper function */
func - (left: Int, right: AKParameter) -> AKDifference {
    return AKDifference(input: akpi(left), minus: right)
}

