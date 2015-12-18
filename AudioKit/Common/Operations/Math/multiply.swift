//
//  multiply.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** times: Multiplication of parameters
     - returns: AKOperation
     - parameter parameter: The amount to multiply
     */
    public func times(parameter: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(parameter)*")
    }
    
    /** scaledBy: Offsetting by way of multiplication
     - returns: AKOperation
     - parameter parameter: The amount to scale by
     */
    public func scaledBy(parameter: AKOperation) -> AKOperation {
        return self.times(parameter)
    }
    /** scaledBy: Offsetting by way of multiplication
     - returns: AKOperation
     - parameter parameter: The amount to scale by
     */
    public func scaledBy(parameter: Double) -> AKOperation {
        return self.times(parameter.ak)
    }
}

/** Helper function for Multiplication
 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func * (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.times(right)
}

/** Helper function for Multiplication
 - returns: AKOperation
 - left: 1st parameter
 - right: Constant parameter
 */
public func * (left: AKOperation, right: Double) -> AKOperation {
    return left.times(right.ak)
}

/** Helper function for Multiplication
 - returns: AKOperation
 - left: Constant parameter
 - right: 2nd parameter
 */
public func * (left: Double, right: AKOperation) -> AKOperation {
    return right.times(left.ak)
}
