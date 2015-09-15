//
//  AKFractionalPart.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

func fractionalPart(parameter: AKParameter) -> AKFractionalPart {
    return AKFractionalPart(input: parameter)
}

/** FractionalPart of the input signal.
*/
@objc class AKFractionalPart : AKParameter {
    
    // MARK: - Properties
    
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the fractionalPart
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
        leftOutput  = abs(input.leftOutput  - floor(input.leftOutput))
        rightOutput = abs(input.rightOutput - floor(input.rightOutput))
    }
    
}
