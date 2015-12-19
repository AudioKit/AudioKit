//
//  subtract.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** minus: Subtraction of operations
     
     - returns: AKOperation
     - parameter subtrahend: The amount to subtract
     */
    public func minus(subtrahend: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(subtrahend)-")
    }
}


/** Helper function for Subtraction
 
 - returns: AKOperation
 - left: 1st operation
 - right: 2nd operation
 */
public func - (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.minus(right)
}

/** Helper function for Subtraction
 
 - returns: AKOperation
 - left: Operation
 - right: Constant value
 */
public func - (left: AKOperation, right: Double) -> AKOperation {
    return left.minus(right.ak)
}

/** Helper function for Subtraction
 
 - returns: AKOperation
 - left: Constant value
 - right: Operation
 */
public func - (left: Double, right: AKOperation) -> AKOperation {
    return left.ak.minus(right)
}
