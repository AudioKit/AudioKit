//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

import Foundation

extension Int {
    var ak: AKConstant {return AKConstant(value: self)}
}
extension Double {
    var ak: AKConstant {return AKConstant(value: self)}
}

extension AKSum {
    convenience init(operands: AKParameter...) {
        self.init()
        self.inputs = operands
    }
}

extension AKProduct {
    convenience init(operands: AKParameter...) {
        self.init()
        self.inputs = operands
    }
}