//
//  AKStereoOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Stereo version of AKComputedParameter
public class AKStereoOperation: AKComputedParameter {

    // MARK: - Dependency Management

    private var inputs = [AKParameter]()
    
    private var savedLocation = -1
    
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
    private var module = ""
    internal var setupSporth = ""

    private var inlineSporth: String {
        if valueText != "" { return valueText }
        var opString = ""
        for input in inputs {
            if input.dynamicType == AKOperation.self {
                if let operation = input as? AKOperation {
                    if operation.savedLocation >= 0 {
                        print(operation)
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
    
    // MARK: - Functions
    
    /// Create a mono signal by dropping the right channel
    public func toMono() -> AKOperation {
        return self.left()
    }
    
    /// Create a mono signal by dropping the right channel
    public func left() -> AKOperation {
        return AKOperation(module: "drop", inputs: self)
    }
    
    /// Create a mono signal by dropping the left channel
    public func right() -> AKOperation {
        return AKOperation(module: "swap drop", inputs: self)
    }
    
    
    /// An operation is requiring a parameter to be stereo, which in this case, it is, so just return self
    public func toStereo() -> AKStereoOperation {
        return self
    }
    
    // MARK: - Initialization
    
    /// Default stereo input to any operation stack
    public static var input = AKStereoOperation("((14 p) (15 p))")

    /// Initialize the stereo operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.valueText = operationString
    }
    
    /// Initialize the stereo operation
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
