//
//  divide.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** dividedBy: Division of operations
     
     - returns: AKOperation
     - parameter operation: The amount to divide
     */
    public func dividedBy(operation: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(operation)/")
    }
    
    /** dividedBy: Division of operations
     
     - returns: AKOperation
     - parameter operation: The amount to divide
     */
    public func dividedBy(constant: Double) -> AKOperation {
        return AKOperation("\(self)\(constant.ak)/")
    }
}

/** Helper function for Division
 
 - returns: AKOperation
 - parameter left: 1st operation
 - parameter right: 2nd operation
 */
public func / (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.dividedBy(right)
}

/** Helper function for Division
 
 - returns: AKOperation
 - parameter left: Operation
 - parameter right: Constant value
 */
public func / (left: AKOperation, right: Double) -> AKOperation {
    return left.dividedBy(right)
}

/** Helper function for Division
 
 - returns: AKOperation
 - parameter left: Constant value
 - parameter right: Operation
 */
public func / (left: Double, right: AKOperation) -> AKOperation {
    return right.dividedBy(left)
}
