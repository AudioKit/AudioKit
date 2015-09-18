//
//  AKMix.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKMix : AKParameter {
    // MARK: - Properties
    
    private var input1 = AKParameter()
    private var input2 = AKParameter()
    private var balancePoint = AKParameter()
    
    /** Instantiates the floored value
    - parameter input: Input signal.
    */
    init(input1 source1Input: AKParameter, input2 source2Input: AKParameter, balancePoint pointInput: AKParameter = 0.5.ak)
    {
        super.init()
        input1 = source1Input
        input2 = source2Input
        balancePoint = pointInput
        dependencies = [input1, input2, pointInput]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = (1.0 - balancePoint.leftOutput) * input1.leftOutput  + balancePoint.leftOutput * input2.leftOutput
        rightOutput = (1.0 - balancePoint.leftOutput) * input1.rightOutput + balancePoint.leftOutput * input2.rightOutput
    }
}