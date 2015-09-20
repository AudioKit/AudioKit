//
//  AKDivision.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Product of two input signals
*/
@objc class AKDivision : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var numerator   = AKParameter()
    /** Input to the mathematical function */
    private var denominator = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the division
    - parameter input: The numerator of the division.
    - parameter dividedBy: The denominator.
    */
    init(_ numeratorInput: AKParameter, dividedBy denominatorInput: AKParameter)
    {
        super.init()
        numerator = numeratorInput
        denominator = denominatorInput
        dependencies = [numerator, denominator]
    }
    
    /** Computation of the next value */
    override func compute() {
        if denominator.leftOutput != 0 {
            leftOutput  = numerator.leftOutput  / denominator.leftOutput
        }
        if denominator.rightOutput != 0 {
            rightOutput = numerator.rightOutput / denominator.rightOutput
        }
    }
}


/** Division helper function */
func / (left: AKParameter, right: AKParameter) -> AKDivision {
    return AKDivision(left, dividedBy: right)
}

/** Division helper function */
func / (left: AKParameter, right: Float) -> AKDivision {
    return AKDivision(left, dividedBy: akp(right))
}

/** Division helper function */
func / (left: Float, right: AKParameter) -> AKDivision {
    return AKDivision(akp(left), dividedBy: right)
}

/** Division helper function */
func / (left: AKParameter, right: Int) -> AKDivision {
    return AKDivision(left, dividedBy: akp(right))
}

/** Division helper function */
func / (left: Int, right: AKParameter) -> AKDivision {
    return AKDivision(akp(left), dividedBy: right)
}
