//
//  AKComputedParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// A computed parameter differs from a regular parameter in that it only exists within an operation (unlike float, doubles, and ints which have a value outside of an operation)
public protocol AKComputedParameter: AKParameter {}

/// An AKOperation is a computed parameter that can be passed to other operations in the same operation node
public struct AKOperation: AKComputedParameter {
    
    /// Default input to any operation stack
    public static var input = AKOperation("(0 p)")
    
    /// Dummy trigger
    public static var trigger = AKOperation("0 p")
    
    /// Call up a numbered parameter to the internal operation
    ///
    /// - returns: AKComputedParameter
    /// - parameter i: Number of the parameter to recall
    ///
    public static func parameters(_ i: Int) -> AKOperation {
        return AKOperation("(\(i+2) p)")
    }
    
    /// Performs absolute value on the operation
    ///
    /// - returns: AKComputedParameter
    ///
    public func abs() -> AKOperation {
        return AKOperation("(\(self) abs)")
    }
    
    /// Performs floor calculation on the operation
    ///
    /// - returns: AKComputedParameter
    ///
    public func floor() -> AKOperation {
        return AKOperation("(\(self) floor)")
    }
    
    /// Returns the fractional part of the operation (as opposed to the integer part)
    ///
    /// - returns: AKComputedParameter
    ///
    public func fract() -> AKOperation {
        return AKOperation("(\(self) frac)")
    }
    
    /// Performs natural logarithm on the operation
    ///
    /// - returns: AKComputedParameter
    ///
    public func log() -> AKOperation {
        return AKOperation("(\(self) log)")
    }
    
    /// Performs Base 10 logarithm on the operation
    ///
    /// - returns: AKComputedParameter
    ///
    public func log10() -> AKOperation {
        return AKOperation("(\(self) log10)")
    }
    
    /// Rounds the operation to the nearest integer
    ///
    /// - returns: AKComputedParameter
    ///
    public func round() -> AKOperation {
        return AKOperation("(\(self) round)")
    }
    
    /// Returns a frequency for a given midi note number
    ///
    /// - returns: AKComputedParameter
    ///
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation("(\(self) mtof)")
    }
    
    /// Sporth representation of the operation
    var operationString = ""
    
    /// Redefining description to return the operation string
    public var description: String {
        return "\(operationString.trimmingCharacters(in: CharacterSet.whitespaces)) "
    }
    
    /// Initialize the operation as a constant value
    ///
    /// - parameter value: Constant value as an operation
    ///
    public init(_ value: Double) {
        self.operationString = "\(value)"
    }
    
    /// Initialize the operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.operationString = operationString
    }
}

/// Performs absolute value on the operation
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func abs(_ parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func floor(_ operation: AKOperation) -> AKOperation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func fract(_ operation: AKOperation) -> AKOperation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func log(_ operation: AKOperation) -> AKOperation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func log10(_ operation: AKOperation) -> AKOperation {
    return operation.log10()
    
}

/// Rounds the operation to the nearest integer
///
/// - returns: AKComputedParameter
/// - parameter operation: AKComputedParameter to operate on
///
public func round(_ operation: AKOperation) -> AKOperation {
    return operation.round()
}
