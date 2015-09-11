//
//  AKParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

func akp(num: Float) -> AKParameter {
    return AKParameter(float: num)
}

extension Int {
    var ak: AKParameter { return AKParameter(float: Float(self)) }
}

extension Float {
    var ak: AKParameter { return AKParameter(float: self) }
    var midiratio: Float { return pow(2, self * 0.083333333333) }
}

extension Double {
    var ak: AKParameter {return AKParameter(float: Float(self))}
    var midiratio: Double {return pow(2, self * 0.083333333333)}
}

/** A parent class for all variables in AudioKit */
@objc class AKParameter : NSObject {
    
    /** Pointers to the SoundPipe floats */
    var leftPointer:  UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    var rightPointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    
    /** The actual value of the parameters */
    var leftOutput:  Float = 0.0 { didSet { leftPointer.memory  = leftOutput  } }
    var rightOutput: Float = 0.0 { didSet { rightPointer.memory = rightOutput } }

    var value: Float = 0.0 {
        didSet {
            leftPointer.memory = value
        }
    }

    
    /**
    An initializer for a constant parameter
    
    - parameter float: The value of the constant parameter
    */
    convenience init(float: Float) {
        self.init()
        leftOutput  = float
        rightOutput = float
    }
    
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