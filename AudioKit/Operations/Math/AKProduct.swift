//
//  AKProduct.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func * (left: AKParameter, right: AKParameter) -> AKProduct {
    return AKProduct(input: left, times: right)
}

/** Product of two input signals
*/
@objc class AKProduct : AKParameter {
    
    // MARK: - Properties
    
    private var first  = AKParameter()
    private var second = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the absoute value
    - parameter input: Input audio signal.
    */
    init(input firstInput: AKParameter, times secondInput: AKParameter)
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
