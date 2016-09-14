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
public class AKOperation: AKComputedParameter {

    // MARK: - Dependency Management
    
    private var inputs = [AKParameter]()

    internal var savedLocation = -1
    
    private var dependencies = [AKOperation]()
    
    internal var recursiveDependencies: [AKOperation] {
        var all = [AKOperation]()
        var uniq = [AKOperation]()
        var added = Set<String>()
        for dep in dependencies {
            all += dep.recursiveDependencies
            all.append(dep)
        }
        
        for elem in all {
            if !added.contains(elem.inlineSporth) {
                uniq.append(elem)
                added.insert(elem.inlineSporth)
            }
        }

        return uniq
    }
    
    // MARK: - String Representations
    
    private var valueText = ""
    internal var setupSporth = ""
    private var module = ""
    
    internal var inlineSporth: String {
        if valueText != "" { return valueText }
        var opString = ""
        for input in inputs {
            if input.dynamicType == AKOperation.self {
                if let operation = input as? AKOperation {
                    if operation.savedLocation >= 0 {
                        opString += "\(operation.savedLocation) \"ak\" tget "
                    } else {
                        opString  += operation.inlineSporth
                    }
                }
            } else {
                opString  += "\(input) "
            }
            
        }
        opString  += "\(module) "
        return opString
    }
    
    /// Final sporth string when this operation is the last operation in the stack
    internal var sporth: String {
        let rd = recursiveDependencies
        var str = "\"ak\" \""
        for _ in rd {
            str += "0 "
        }
        str += "\" gen_vals \n"
        
        var counter = 0
        for op in rd {
            op.savedLocation = counter
            str += "\(op.setupSporth) \n"
            str += "\(op.inlineSporth) \(op.savedLocation) \"ak\" tset\n"
            counter += 1
        }
        str += "\(setupSporth) \n"
        str += "\(inlineSporth) \n"
        return str
    }
    
    /// Redefining description to return the operation string
    public var description: String {
        return inlineSporth
    }
    
    // MARK: - Inputs
    
    /// Left input to any stereo operation
    public static var leftInput = AKOperation("(14 p)")

    /// Right input to any stereo operation
    public static var rightInput = AKOperation("(15 p)")
    
    /// Dummy trigger
    public static var trigger = AKOperation("(0 p)")
    
    // MARK: - Functions
    
    /// An= array of 14 parameters which may be sent to operations
    public static var parameters: [AKOperation] =
        [AKOperation("(0 p)"),
         AKOperation("(1 p)"),
         AKOperation("(2 p)"),
         AKOperation("(3 p)"),
         AKOperation("(4 p)"),
         AKOperation("(5 p)"),
         AKOperation("(6 p)"),
         AKOperation("(7 p)"),
         AKOperation("(8 p)"),
         AKOperation("(9 p)"),
         AKOperation("(10 p)"),
         AKOperation("(11 p)"),
         AKOperation("(12 p)"),
         AKOperation("(13 p)")]
    
    
    /// Convert the operation to a mono operation
    public func toMono() -> AKOperation {
        return self
    }

    /// Performs absolute value on the operation
    public func abs() -> AKOperation {
        return AKOperation(module: "abs", inputs: self)
    }

    /// Performs floor calculation on the operation
    public func floor() -> AKOperation {
        return AKOperation(module: "floor", inputs: self)
    }

    /// Returns the fractional part of the operation (as opposed to the integer part)
    public func fract() -> AKOperation {
        return AKOperation(module: "frac", inputs: self)
    }

    /// Performs natural logarithm on the operation
    public func log() -> AKOperation {
        return AKOperation(module: "log", inputs: self)
    }

    /// Performs Base 10 logarithm on the operation
    public func log10() -> AKOperation {
        return AKOperation(module: "log10", inputs: self)
    }

    /// Rounds the operation to the nearest integer
    public func round() -> AKOperation {
        return AKOperation(module: "round", inputs: self)
    }

    /// Returns a frequency for a given midi note number
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation(module: "mtof", inputs: self)
    }

    // MARK: - Initialization
    
    /// Initialize the operation as a constant value
    ///
    /// - parameter value: Constant value as an operation
    ///
    public init(_ value: Double) {
        self.valueText = "\(value)"
    }

    init(global: String) {
        self.valueText = global
    }
    
    /// Initialize the operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.valueText = operationString
        //self.tableIndex = -1 //AKOperation.nextTableIndex
        //AKOperation.nextTableIndex += 1
        //AKOperation.operationArray.append(self)
    }
    
    /// Initialize the operation
    ///
    /// - parameter module: Sporth unit generator
    /// - parameter setup:  Any setup Sporth code that this operation may require
    /// - parameter inputs: All the parameters of the operation
    ///
    public init(module: String, setup: String = "",  inputs: AKParameter...) {
        self.module = module
        self.setupSporth = setup
        self.inputs = inputs
        
        for input in inputs {
            if input.dynamicType == AKOperation.self {
                if let forcedInput = input as? AKOperation {
                    dependencies.append(forcedInput)
                }
            }
        }
    }
}

// MARK: - Global Functions 

/// Performs absolute value on the operation
///
/// - parameter parameter: AKComputedParameter to operate on
///
public func abs(_ parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func floor(_ operation: AKOperation) -> AKOperation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - parameter operation: AKComputedParameter to operate on
///
public func fract(_ operation: AKOperation) -> AKOperation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func log(_ operation: AKOperation) -> AKOperation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - parmeter operation: AKComputedParameter to operate on
///
public func log10(_ operation: AKOperation) -> AKOperation {
    return operation.log10()

}

/// Rounds the operation to the nearest integer
///
/// - parameter operation: AKComputedParameter to operate on
///
public func round(_ operation: AKOperation) -> AKOperation {
    return operation.round()
}
