//
//  add.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    /** plus: Addition/Summation of operations

     - returns: AKOperation
     - parameter parameter: The amount to add
     */
    public func plus(parameter: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(parameter) +)")
    }

    /** offsetBy: Offsetting by way of addition

     - returns: AKOperation
     - parameter parameter: The amount to offset by
     */
    public func offsetBy(parameter: AKParameter) -> AKOperation {
        return self.plus(parameter)
    }
}

/** Helper function for addition

- returns: AKOperation
- left: 1st parameter
- right: 2nd parameter
*/
public func +(left: AKParameter, right: AKParameter) -> AKOperation {
    return left.plus(right)
}
