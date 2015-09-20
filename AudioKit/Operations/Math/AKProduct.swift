
//
//  AKProduct.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Product of two input signals
*/
@objc class AKProduct : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
   private var first  = AKParameter()
    /** Input to the mathematical function */
    private var second = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the product
    - parameter input: The first input.
    - parameter times: The second input.
    */
    init(_ firstInput: AKParameter, times secondInput: AKParameter)
    {
        super.init()
        first = firstInput
        second = secondInput
        dependencies = [first, second]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = first.leftOutput  * second.leftOutput
        rightOutput = first.rightOutput * second.rightOutput
    }
}

/** Multiplication helper function */
func * (left: AKParameter, right: AKParameter) -> AKProduct {
    return AKProduct(left, times: right)
}

/** Multiplication helper function */
func * (left: AKParameter, right: Float) -> AKProduct {
    return AKProduct(left, times: akp(right))
}

/** Multiplication helper function */
func * (left: Float, right: AKParameter) -> AKProduct {
    return AKProduct(akp(left), times: right)
}

/** Multiplication helper function */
func * (left: AKParameter, right: Int) -> AKProduct {
    return AKProduct(left, times: akp(right))
}

/** Multiplication helper function */
func * (left: Int, right: AKParameter) -> AKProduct {
    return AKProduct(akp(left), times: right)
}
