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
class AKParameter {

    /** A pointer to the SoundPipe float */
    var pointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    
    /** The actual value of the parameter */
    var value: Float = 0.0 { didSet { pointer.memory = value } }
    
    /** 
    An initializer for a constant parameter 
    
    :param: float The value of the constant parameter
    */
    convenience init(float: Float) {
        self.init()
        value = float
    }
    
    /** Bind the memory of the SoundPipe value to this parameter */
    func bind(binding:UnsafeMutablePointer<Float>) {
        pointer = binding
        pointer.memory = value
    }
    
    /** The compute function to override in subclasses */
    func compute() -> Float {
        // override in subclass
        return 0.0
    }
    
    /** A placeholder for a function to release the memory */
    func teardown() {
        // override in subclass
    }
    
    
}