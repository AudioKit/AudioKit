//
//  AKFloor.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Floor of the input signal.
*/
@objc class AKFloor : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
   private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the floored value
    
    - parameter input: Input signal.
    */
    init(_ input: AKParameter)
    {
        super.init()
        self.input = input
        dependencies = [input]
    }
    
    /** Computation of the next value */
    override func compute() {
        leftOutput  = floor(input.leftOutput)
        rightOutput = floor(input.rightOutput)
    }
}

/** Floor helper function */
func floor(parameter: AKParameter) -> AKFloor {
    return AKFloor(parameter)
}
