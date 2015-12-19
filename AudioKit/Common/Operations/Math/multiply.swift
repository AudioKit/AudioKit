//
//  multiply.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** times: Multiplication of operations
     
     - returns: AKOperation
     - parameter operation: The amount to multiply
     */
    public func times(operation: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(operation)*")
    }
    
    /** scaledBy: Offsetting by way of multiplication
     
     - returns: AKOperation
     - parameter operation: The amount to scale by
     */
    public func scaledBy(operation: AKOperation) -> AKOperation {
        return self.times(operation)
    }
    /** scaledBy: Offsetting by way of multiplication
     
     - returns: AKOperation
     - parameter constant: The amount to scale by
     */
    public func scaledBy(constant: Double) -> AKOperation {
        return self.times(constant.ak)
    }
}

/** *: Helper function for Multiplication
 
 - returns: AKOperation
 - left: 1st operation
 - right: 2nd operation
 */
public func * (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.times(right)
}

/** *: Helper function for Multiplication
 
 - returns: AKOperation
 - left: Operation
 - right: Constant value
 */
public func * (left: AKOperation, right: Double) -> AKOperation {
    return left.times(right.ak)
}

/** *: Helper function for Multiplication
 
 - returns: AKOperation
 - left: Constant value
 - right: Operation
 */
public func * (left: Double, right: AKOperation) -> AKOperation {
    return right.times(left.ak)
}
