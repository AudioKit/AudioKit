//
//  AKOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public struct AKOperation: CustomStringConvertible {

    public static var input = AKOperation("0 p 1 p")

    var operationString = ""
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    public init(_ operationString: String) {
        self.operationString = operationString
    }
    public init(value: Float) {
        operationString = "\(value)"
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
    public func midiNoteToFrequency() -> AKOperation {
        return AKOperation("\(self)mtof")
    }
}

public func abs(operation: AKOperation) -> AKOperation {
    return operation.abs()
}

public func floor(operation: AKOperation) -> AKOperation {
    return operation.floor()
}

public func fract(operation: AKOperation) -> AKOperation {
    return operation.fract()
}

public func log(operation: AKOperation) -> AKOperation {
    return operation.log()
}

public func log10(operation: AKOperation) -> AKOperation {
    return operation.log10()
}

public func round(operation: AKOperation) -> AKOperation {
    return operation.round()
}

public struct AKStereoOperation: CustomStringConvertible {
    var operationString = ""
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        self.operationString = operationString
    }
    public func toMono() -> AKOperation {
        return AKOperation("\(self)drop")
    }
}

public func ak(value: Float) -> AKOperation {
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


