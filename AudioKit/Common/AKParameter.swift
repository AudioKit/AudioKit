//
//  AKParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public struct AKParameter: CustomStringConvertible {
    var parameterString = ""
    public var description: String {
        return " \(parameterString) "
    }
    init(_ operationString: String) {
        parameterString = operationString
    }
    public init(value: Float) {
        parameterString = "\(value) "
    }
}

public struct AKP {
    
    public enum SinePreset {
        case Fast
        case Slow
    }
    public static func sine(frequency frequency: AKParameter = AKParameter(value: 440),
        amplitude: AKParameter = AKParameter(value: 1)) -> AKParameter {
            return AKParameter("\(frequency) \(amplitude) sine")
    }
    public static func sine(preset preset: SinePreset) -> AKParameter {
        switch preset {
        case .Fast:
            return AKParameter("10 1 sine")
        case .Slow:
            return AKParameter("0.1 1 sine")
        }
    }

    public static func scale(input: AKParameter, minimum: AKParameter = 0.ak, maximum: AKParameter = 1.ak) -> AKParameter {
        return AKParameter("\(input) \(minimum) \(maximum) scale")
    }
}

public func akp(value: Float) -> AKParameter {
    return AKParameter(value: value)
}

public extension Int {
    public var ak: AKParameter {return AKParameter(value: Float(self))}
}

public extension Float {
    public var ak: AKParameter {return AKParameter(value: self)}
}
public extension Double {
    public var ak: AKParameter {return AKParameter(value: Float(self))}
}

public func AKNewGenerator(operation: AKParameter) -> AKCustomGenerator {
    return AKCustomGenerator("\(operation) dup")
}

public func AKNewGenerator(left: AKParameter, _ right: AKParameter) -> AKCustomGenerator {
    return AKCustomGenerator("\(left) \(right)")
}