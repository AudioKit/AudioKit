//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/3/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

func akp(num: Float) -> AKConstant {
    return AKConstant(float: num)
}

func akpi(num: Int) -> AKConstant {
    return AKConstant(integer: num)
}

func akps(str: String) -> AKConstant {
    return AKConstant(string: str)
}

func akpfn(file: String) -> AKConstant {
    return AKConstant(filename: file)
}

extension Int {
    var ak: AKConstant {return AKConstant(integer: self)}
}

extension Float {
    var ak: AKConstant {return AKConstant(float: self)}
    var midiratio: Float {return pow(2, self * 0.083333333333)}
}

extension Double {
    var ak: AKConstant {return AKConstant(float: Float(self))}
    var midiratio: Double {return pow(2, self * 0.083333333333)}
}

extension AKMultipleInputMathOperation {
    convenience init(inputs: AKParameter...) {
        self.init()
        self.inputs = inputs
    }
}

// Arithmetic operators

func + (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.plus(right)
}

func + (left: AKControl, right: AKControl) -> AKControl {
    return left.plus(right)
}

func + (left: AKConstant, right: AKConstant) -> AKConstant {
    return left.plus(right)
}

func - (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.minus(right)
}

func - (left: AKControl, right: AKControl) -> AKControl {
    return left.minus(right)
}

func - (left: AKConstant, right: AKConstant) -> AKConstant {
    return left.minus(right)
}

func * (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.scaledBy(right)
}

func * (left: AKControl, right: AKControl) -> AKControl {
    return left.scaledBy(right)
}

func * (left: AKConstant, right: AKConstant) -> AKConstant {
    return left.scaledBy(right)
}

func / (left: AKParameter, right: AKParameter) -> AKParameter {
    return left.dividedBy(right)
}

func / (left: AKControl, right: AKControl) -> AKControl {
    return left.dividedBy(right)
}

func / (left: AKConstant, right: AKConstant) -> AKConstant {
    return left.dividedBy(right)
}