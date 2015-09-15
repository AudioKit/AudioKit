//
//  AKParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

// MARK: - Parameter related functions and extensions

/** Constant parameter helper function
- parameter num: Floating point constant
*/
func akp(num: Float) -> AKParameter {
    /** Returns an AKParameter with a constant value */
    return AKParameter(float: num)
}

/** AudioKit extension to Int */
extension Int {
    /** Returns an AKParameter with a constant value */
    var ak: AKParameter { return AKParameter(float: Float(self)) }
}

/** AudioKit extension to Float */
extension Float {
    /** Returns an AKParameter with a constant value */
    var ak: AKParameter { return AKParameter(float: self) }
    /** Returns an AKParameter with a MIDI ratio */
    var midiratio: Float { return pow(2, self * 0.083333333333) }
}

/** AudioKit extension to Double */
extension Double {
    /** Returns an AKParameter with a constant value */
    var ak: AKParameter {return AKParameter(float: Float(self))}
    /** Returns an AKParameter with a MIDI ratio */
    var midiratio: Double {return pow(2, self * 0.083333333333)}
}

/** A parent class for all variables in AudioKit */
@objc class AKParameter : NSObject {
    
    // MARK: - Properties
    
    /** Pointer to the SoundPipe for the left channel */
    var leftPointer:  UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    /** Pointer to the SoundPipe for the right channel */
    var rightPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    
    /** The internal value of the left output */
    dynamic var leftOutput:  Float = 0.0 { didSet { leftPointer.memory  = leftOutput  } }
    /** The internal value of the right output */
    dynamic var rightOutput: Float = 0.0 { didSet { rightPointer.memory = rightOutput } }

    /** The internal value for mono signals */
    var value: Float = 0.0 {
        didSet {
            leftPointer.memory = value
            self.leftOutput = value
            self.rightOutput = value
        }
    }

    /** All other parameters this operation depends on */
    var dependencies = [AKParameter]()
    
    /** This tells us whether we've already connected this operation to the instrument */
    var connected: Bool
    
    // MARK: - Initializers
    
    /** Basic initializer */
    override init() {
        connected = false
        super.init()
    }
    
    /**
    An initializer for a constant parameter
    
    - parameter float: The value of the constant parameter
    */
    convenience init(float: Float) {
        self.init()
        leftOutput  = float
        rightOutput = float
        connected = true
    }
    
    // MARK: - Math Helpers
    
    /** Multiplication helper 
    - parameter parameter: The AKParameter to multiply by */
    func scaledBy(parameter: AKParameter) -> AKProduct {
        return AKProduct(input: self, times: parameter)
    }
    
    /** Division helper
    - parameter parameter: The AKParameter to divide by */
    func dividedBy(parameter: AKParameter) -> AKDivision {
        return AKDivision(input: self, dividedBy: parameter)
    }
    
    /** Summation helper
    - parameter parameter: The AKParameter to add to */
    func plus(parameter: AKParameter) -> AKSum {
        return AKSum(input: self, plus: parameter)
    }
    
    /** Subtraction helper
    - parameter parameter: The AKParameter to subtract */
    func minus(parameter: AKParameter) -> AKDifference {
        return AKDifference(input: self, minus: parameter)
    }
    
    // MARK: - Internal
    
    /** Bind the memory of the SoundPipe value to this parameter */
    func bind(binding:UnsafeMutablePointer<Float>)
    {
        leftPointer = binding
        leftPointer.memory = leftOutput        
    }
    
    /** The compute function to override in subclasses */
    func compute() {
        // override in subclass
    }
    
    /** A placeholder for a function to release the memory */
    func teardown() {
        // override in subclass
    }
    
    
}