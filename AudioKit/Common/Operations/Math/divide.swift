//
//  divide.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    /** dividedBy: Division of parameters

     - returns: AKOperation
     - parameter parameter: The amount to divide
     */
    public func dividedBy(parameter: AKParameter) -> AKOperation {
        return AKOperation("(\(self) \(parameter) /)")
    }
}

/** Helper function for Division

 - returns: AKOperation
 - parameter left: 1st parameter
 - parameter right: 2nd parameter
 */
public func / (left: AKParameter, right: AKParameter) -> AKOperation {
    return left.dividedBy(right)
}

