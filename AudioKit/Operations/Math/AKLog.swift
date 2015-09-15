//
//  AKLog.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/14/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Natural log helper function */
func log(parameter: AKParameter) -> AKLog {
    return AKLog(input: parameter)
}

/** Log of the input signal.
*/
@objc class AKLog : AKParameter {
    
    // MARK: - Properties
    
    /** Input to the mathematical function */
    private var input = AKParameter()
    
    // MARK: - Initializers
    
    /** Instantiates the log
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
        leftOutput  = log(input.leftOutput)
        rightOutput = log(input.rightOutput)
    }
    
}
