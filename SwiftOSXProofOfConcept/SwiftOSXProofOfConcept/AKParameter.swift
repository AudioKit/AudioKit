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

class AKParameter {

    var pointer: UnsafeMutablePointer<Float> = UnsafeMutablePointer.alloc(1)
    var value: Float = 0.0
    
    convenience init(float: Float) {
        self.init()
        value = float
    }
    
    func bind(binding:UnsafeMutablePointer<Float>) {
        pointer = binding
        pointer.memory = value
    }
    
    func compute() -> Float {
        // override in subclass
        return 0.0
    }
    
    func teardown() {
        // override in subclass
    }
    
    
}