//
//  AKComputedParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// A computed parameter differs from a regular parameter in that it only exists within an operation (unlike float, doubles, and ints which have a value outside of an operation)
public protocol AKComputedParameter: AKParameter {
    func operationString() -> String
    func setupString() -> String
}

/// An AKOperation is a computed parameter that can be passed to other operations in the same operation node
public struct AKOperation: AKComputedParameter {
    public func operationString() -> String {
        return opString
    }
    public func setupString() -> String {
        return setup
    }
    public static var nextTableIndex = 0
    public var tableIndex: Int = -1
    public static var operationArray = [AKComputedParameter]()
    public var module = ""
    public var setup = ""
    public var dependencies = [AKOperation]()
    
    public var recursiveDependencies: [String] {
        var all = [String]()
        var uniq = [String]()
        var added = Set<String>()
        for dep in dependencies {
            all += dep.recursiveDependencies
            all.append(dep.opString)
        }
        
        for elem in all {
            if !added.contains(elem) {
                uniq.append(elem)
                added.insert(elem)
            }
        }

        return uniq
    }
    
    public var sporth: String {
        var str = "\"ak\" \""
        for _ in AKOperation.operationArray { //dependencies {
            str += "0 "
//            for _ in op.dependencies {
//                str += "0 "
//            }
        }
        str += "\" gen_vals \n"
        
        var counter = 0
        for op in AKOperation.operationArray {
            if recursiveDependencies.contains(op.operationString()) { // && op.tableIndex >= 0 {
                str += "\(op.setupString()) \n"
                str += "\(op.operationString()) \(counter) \"ak\" tset\n"
            }
            counter += 1
        }
        str += "\(setup) \n"
        str += "\(operationString()) \n"
        return str
    }
    
    /// Default input to any operation
    public static var input = AKOperation("(14 p)")
    
    /// Left input to any stereo operation
    public static var leftInput = AKOperation("(14 p)")

    /// Right input to any stereo operation
    public static var rightInput = AKOperation("(15 p)")
    
    /// Dummy trigger
    public static var trigger = AKOperation("(0 p)")

    /// Call up a numbered parameter to the internal operation
    ///
    /// - parameter i: Number of the parameter to recall
    ///
    public static func parameters(i: Int) -> AKOperation {
        return AKOperation("(\(i) p)")
    }
    
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

    /// Sporth representation of the operation
    public var opString = ""

    /// Redefining description to return the operation string
    public var description: String {
        if tableIndex < 0 {
            return operationString()
        } else {
            return "\(tableIndex) \"ak\" tget"
        }
        //return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }

    /// Initialize the operation as a constant value
    ///
    /// - parameter value: Constant value as an operation
    ///
    public init(_ value: Double) {
        self.opString = "\(value)"
    }

    init(global: String) {
        self.opString = global
    }
    
    /// Initialize the operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.opString = operationString
        //self.tableIndex = -1 //AKOperation.nextTableIndex
        //AKOperation.nextTableIndex += 1
        //AKOperation.operationArray.append(self)
    }
    
    public init(module: String, setup: String = "",  inputs: AKParameter...) {
        self.module = module
        self.setup = setup

        for input in inputs {
            self.opString  += "\(input) "
            if input.dynamicType == AKOperation.self {
                if let forcedInput = input as? AKOperation {
                    dependencies.append(forcedInput)
                }
            }
            
        }
        self.opString  += "\(module) "
        self.tableIndex = AKOperation.nextTableIndex
        AKOperation.nextTableIndex += 1
        AKOperation.operationArray.append(self)
    }
}

/// Performs absolute value on the operation
///
/// - parameter parameter: AKComputedParameter to operate on
///
public func abs(parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

/// Performs floor calculation on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func floor(operation: AKOperation) -> AKOperation {
    return operation.floor()
}

/// Returns the fractional part of the operation (as opposed to the integer part)
///
/// - parameter operation: AKComputedParameter to operate on
///
public func fract(operation: AKOperation) -> AKOperation {
    return operation.fract()
}

/// Performs natural logarithm on the operation
///
/// - parameter operation: AKComputedParameter to operate on
///
public func log(operation: AKOperation) -> AKOperation {
    return operation.log()
}

/// Performs Base 10 logarithm on the operation
///
/// - parmeter operation: AKComputedParameter to operate on
///
public func log10(operation: AKOperation) -> AKOperation {
    return operation.log10()

}

/// Rounds the operation to the nearest integer
///
/// - parameterd operation: AKComputedParameter to operate on
///
public func round(operation: AKOperation) -> AKOperation {
    return operation.round()
}
