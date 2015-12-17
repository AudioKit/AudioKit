//
//  AKOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public struct AKOperation: CustomStringConvertible {
    var parameterString = ""
    public var description: String {
        return "\(parameterString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        parameterString = operationString
    }
    public init(value: Float) {
        parameterString = "\(value)"
    }
    public func abs() -> AKOperation {
        return AKOperation("\(self)abs")
    }
    public func floor() -> AKOperation {
        return AKOperation("\(self)floor")
    }
    public func fract() -> AKOperation {
        return AKOperation("\(self)frac")
    }
    public func log() -> AKOperation {
        return AKOperation("\(self)log")
    }
    public func log10() -> AKOperation {
        return AKOperation("\(self)log10")
    }
    public func round() -> AKOperation {
        return AKOperation("\(self)round")
    }
    public func midiNoteNumberToFrequency() -> AKOperation {
        return AKOperation("\(self)mtof")
    }
}

public func abs(parameter: AKOperation) -> AKOperation {
    return parameter.abs()
}

public func floor(parameter: AKOperation) -> AKOperation {
    return parameter.floor()
}

public func fract(parameter: AKOperation) -> AKOperation {
    return parameter.fract()
}

public func log(parameter: AKOperation) -> AKOperation {
    return parameter.log()
}

public func log10(parameter: AKOperation) -> AKOperation {
    return parameter.log10()
}

public func round(parameter: AKOperation) -> AKOperation {
    return parameter.round()
}

public struct AKStereoOperation: CustomStringConvertible {
    var parameterString = ""
    public var description: String {
        return "\(parameterString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        parameterString = operationString
    }
}

public let AKInput = AKOperation("0 p 1 p")

public func akp(value: Float) -> AKOperation {
    return AKOperation(value: value)
}

public extension Int {
    public var ak: AKOperation {return AKOperation(value: Float(self))}
}

public extension Float {
    public var ak: AKOperation {return AKOperation(value: self)}
}
public extension Double {
    public var ak: AKOperation {return AKOperation(value: Float(self))}
}


