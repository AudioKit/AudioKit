//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

func akp(num: Float)->AKConstant {
    return AKConstant(value: num)
}

func akpi(num: Int)->AKConstant {
    return AKConstant(value: num)
}

extension Int {
    var ak: AKConstant {return AKConstant(value: self)}
}
extension Float {
    var ak: AKConstant {return AKConstant(value: self)}
}
extension Double {
    var ak: AKConstant {return AKConstant(value: self)}
}

extension AKMultipleInputMathOperation {
    convenience init(inputs: AKParameter...) {
        self.init()
        self.inputs = inputs
    }
}