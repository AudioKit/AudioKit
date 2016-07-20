//
//  AKStereoOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Stereo version of AKComputedParameter
public struct AKStereoOperation: AKComputedParameter {
    
    /// Default stereo input to any operation stack
    public static var input = AKStereoOperation("((14 p) (15 p))")
    
    /// Sporth representation of the stereo operation
    var opString = ""
    var module = ""
    var setup = ""
    var tableIndex = -1
    
    public func operationString() -> String {
        return opString
    }
    
    public func setupString() -> String {
        return setup
    }
    
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
    
    /// Redefining description to return the operation string
    public var description: String {
        return "\(opString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    
    /// Initialize the stereo operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.opString = operationString
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
}
