//
//  AKOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public protocol AKParameter: CustomStringConvertible {
}

extension AKParameter {
    public func abs() -> AKOperation {
        return AKOperation("\(self) abs ")
    }
    public func floor() -> AKOperation {
        return AKOperation("\(self) floor ")
    }
    public func fract() -> AKOperation {
        return AKOperation("\(self) frac ")
    }
    public func log() -> AKOperation {
        return AKOperation("\(self) log ")
    }
    public func log10() -> AKOperation {
        return AKOperation("\(self) log10 ")
    }
    public func round() -> AKOperation {
        return AKOperation("\(self) round ")
    }
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation("\(self) mtof ")
    }
}

extension Double: AKParameter {}
extension Float: AKParameter {}
extension Int: AKParameter {}

public struct AKOperation: AKParameter  {

    public static var input = AKOperation("0 p ")
    public static var trigger = AKOperation("")

    public static func parameters(i: Int) -> AKOperation {
        return AKOperation("\(i+1)  p  ")
    }

    var operationString = ""
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    public init(_ operationString: String) {
        self.operationString = operationString
    }
    public init(value: Float) {
        operationString = "\(value) "
    }
}

public func abs(parameter: AKParameter) -> AKOperation {
    return parameter.abs()
}

public func floor(parameter: AKParameter) -> AKOperation {
    return parameter.floor()
}

public func fract(parameter: AKParameter) -> AKOperation {
    return parameter.fract()
}

public func log(parameter: AKParameter) -> AKOperation {
    return parameter.log()
}

public func log10(parameter: AKParameter) -> AKOperation {
    return parameter.log10()
}

public func round(parameter: AKParameter) -> AKOperation {
    return parameter.round()
}

public struct AKStereoOperation: CustomStringConvertible {
    public static var input = AKStereoOperation("0 p 1 p ")
    var operationString = ""
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        self.operationString = operationString
    }
    public func toMono() -> AKOperation {
        return AKOperation("\(self) drop ")
    }
}

