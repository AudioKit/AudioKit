//
//  multiply.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    /** times: Multiplication of parameters

     - returns: AKOperation
     - parameter parameter: The amount to multiply
     */
    public func times(parameter: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(parameter) *)")
    }

    /** scaledBy: Offsetting by way of multiplication

     - returns: AKOperation
     - parameter parameter: The amount to scale by
     */
    public func scaledBy(parameter: AKParameter) -> AKOperation {
        return self.times(parameter)
    }
}

/** *: Helper function for Multiplication

 - returns: AKOperation
 - left: 1st parameter
 - right: 2nd parameter
 */
public func * (left: AKParameter, right: AKParameter) -> AKOperation {
    return left.times(right)
}

