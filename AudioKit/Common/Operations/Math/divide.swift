//
//  divide.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** dividedBy: Division of parameters
     - returns: AKOperation
     - parameter parameter: The amount to divide
     */
    public func dividedBy(parameter: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(parameter)/")
    }
    
    /** dividedBy: Division of parameters
     - returns: AKOperation
     - parameter parameter: The amount to divide
     */
    public func dividedBy(parameter: Double) -> AKOperation {
        return AKOperation("\(self)\(parameter.ak)/")
    }
}

/** Helper function for Division
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func / (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.dividedBy(right)
}

/** Helper function for Division
 - returns: AKOperation
 - left: 1st parameter
 - right: Constant parameter
 */
public func / (left: AKOperation, right: Double) -> AKOperation {
    return left.dividedBy(right)
}

/** Helper function for Division
 - returns: AKOperation
 - left: Constant parameter
 - right: 2nd parameter
 */
public func / (left: Double, right: AKOperation) -> AKOperation {
    return right.dividedBy(left)
}
