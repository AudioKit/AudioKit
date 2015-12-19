//
//  mix.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Mix together two operations
 
 - returns: AKOperations
 - parameter first: First operation
 - parameter second: Second operation
 - parameter t: Value from zero to one indicating balance between first (0) and second (1) (Default: 0.5)
 */
public func mix(first: AKOperation, _ second: AKOperation, t: Double = 0.5) -> AKOperation {
    return mix(first, second, t: t.ak)
}

/** Mix together two operations
 
 - returns: AKOperations
 - parameter first: First operation
 - parameter second: Second operation
 - parameter t: Value from zero to one indicating balance between first (0) and second (1) (Default: 0.5)
 */
public func mix(first: AKOperation, _ second: AKOperation, t: AKOperation = 0.5.ak) -> AKOperation {
    let firstRatio = 1.0 - t
    return AKOperation("\(firstRatio * first)\(t * second)+")
}