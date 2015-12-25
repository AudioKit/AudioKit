//
//  AKOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// AKParameter is a subset of CustomStringConvertible
public protocol AKParameter: CustomStringConvertible {}

/// Doubles are valid AKParameters
extension Double: AKParameter {}

/// Floats are valid AKParameters
extension Float: AKParameter {}

/// Integers are valid AKParameters
extension Int: AKParameter {}

/// An AKOperation is a block of Sporth code that can be passed to other operations in the same operation node
public struct AKOperation: AKParameter  {
    
    /// Default input to any operation stack
    public static var input = AKOperation("(0 p)")
    
    /// Dummy trigger
    public static var trigger = AKOperation("")
    
    /** Call up a numbered parameter to the internal operation
     
     - returns: AKOperation
     - parameter i: Number of the parameter to recall
     */
    public static func parameters(i: Int) -> AKOperation {
        return AKOperation("(\(i+1) p)")
    }
    
    /** Performs absolute value on the operation
     
     - returns: AKOperation
     */
    public func abs() -> AKOperation {
        return AKOperation("(\(self) abs)")
    }
    
    /** Performs floor calculation on the operation
     
     - returns: AKOperation
     */
    public func floor() -> AKOperation {
        return AKOperation("(\(self) floor)")
    }
    
    /** Returns the fractional part of the operation (as opposed to the integer part)
     
     - returns: AKOperation
     */
    public func fract() -> AKOperation {
        return AKOperation("(\(self) frac)")
    }
    
    /** Performs natural logarithm on the operation
     
     - returns: AKOperation
     */
    public func log() -> AKOperation {
        return AKOperation("(\(self) log)")
    }
    
    /** Performs Base 10 logarithm on the operation
     
     - returns: AKOperation
     */
    public func log10() -> AKOperation {
        return AKOperation("(\(self) log10)")
    }
    
    /** Rounds the operation to the nearest integer
     
     - returns: AKOperation
     */
    public func round() -> AKOperation {
        return AKOperation("(\(self) round)")
    }
    
    /** Returns a frequency for a given midi note number
     
     - returns: AKOperation
     */
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation("(\(self) mtof)")
    }
    
    /// Sporth representation of the operation
    var operationString = ""
    
    /// Redefining description to return the operation string
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    
    /** Initialize the operation with a Sporth string
     
     - parameter operationString: Valid Sporth string (proceed with caution
     */
    public init(_ operationString: String) {
        self.operationString = operationString
    }
}

/** Performs absolute value on the operation
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func abs(parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

/** Performs floor calculation on the operation
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func floor(operation: AKOperation) -> AKOperation {
    return operation.floor()
}

/** Returns the fractional part of the operation (as opposed to the integer part)
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func fract(operation: AKOperation) -> AKOperation {
    return operation.fract()
}

/** Performs natural logarithm on the operation
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func log(operation: AKOperation) -> AKOperation {
    return operation.log()
}

/** Performs Base 10 logarithm on the operation
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func log10(operation: AKOperation) -> AKOperation {
    return operation.log10()
    
}

/** Rounds the operation to the nearest integer
 
 - returns: AKOperation
 - parameter operation: AKOperation to operate on
 */
public func round(operation: AKOperation) -> AKOperation {
    return operation.round()
}

/// Stereo version of AKOperation
public struct AKStereoOperation: CustomStringConvertible {
    
    /// Default stereo input to any operation stack
    public static var input = AKStereoOperation("((0 p) (1 p))")
    
    /// Sporth representation of the stereo operation
    var operationString = ""
    
    /// Redefining description to return the operation string
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    
    /** Initialize the stereo operation with a Sporth string
     
     - parameter operationString: Valid Sporth string (proceed with caution
     */
    init(_ operationString: String) {
        self.operationString = operationString
    }
    
    /// Create a mono signal by droppigng the right channel
    public func toMono() -> AKOperation {
        return AKOperation("(\(self) drop)")
    }
}

