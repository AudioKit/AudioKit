//
//  add.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    /** plus: Addition/Summation of operations
     
     - returns: AKOperation
     - parameter operation: The amount to add
     */
    public func plus(operation: AKOperation) -> AKOperation {
        return AKOperation("\(self)\(operation)+")
    }
    
    /** plus: Addition/Summation of operations
     
     - returns: AKOperation
     - parameter constant: The amount to add
     */
    public func plus(constant: Double) -> AKOperation {
        return AKOperation("\(self)\(constant.ak)+")
    }
    
    /** offsetBy: Offsetting by way of addition
     
     - returns: AKOperation
     - parameter operation: The amount to offset by
     */
    public func offsetBy(operation: AKOperation) -> AKOperation {
        return self.plus(operation)
    }
    /** offsetBy: Offsetting by way of addition
     
     - returns: AKOperation
     - parameter constant: The amount to offset by
     */
    public func offsetBy(constant: Double) -> AKOperation {
        return self.plus(constant.ak)
    }
}

/** Helper function for addition
 
- returns: AKOperation
- left: 1st operation
- right: 2nd operation
*/
public func + (left: AKOperation, right: AKOperation) -> AKOperation {
    return left.plus(right)
}

/** Helper function for addition
 
 - returns: AKOperation
 - left: Operation
 - right: Constant value
 */
public func + (left: AKOperation, right: Double) -> AKOperation {
    return left.plus(right)
}

/** Helper function for addition
 
 - returns: AKOperation
 - left: Constant value
 - right: Operation
 */
public func + (left: Double, right: AKOperation) -> AKOperation {
    return right.plus(left)
}
