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
     - returns: AKParameter
     - parameter parameter: The amount to divide
     */
    public func dividedBy(parameter: AKParameter) -> AKParameter {
        return AKParameter("\(self)\(parameter)/")
    }
    
    /** dividedBy: Division of parameters
     - returns: AKParameter
     - parameter parameter: The amount to divide
     */
    public func dividedBy(parameter: Double) -> AKParameter {
        return AKParameter("\(self)\(parameter.ak)/")
    }
}

/** Helper function for Division
 - returns: AKParameter
 - left: 1st parameter
 - right: 2nd parameter
 */
public func / (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.dividedBy(right)
}

/** Helper function for Division
 - returns: AKParameter
 - left: 1st parameter
 - right: Constant parameter
 */
public func / (left: AKParameter, right: Double) -> AKParameter {
    return left.dividedBy(right)
}

/** Helper function for Division
 - returns: AKParameter
 - left: Constant parameter
 - right: 2nd parameter
 */
public func / (left: Double, right: AKParameter) -> AKParameter {
    return right.dividedBy(left)
}
