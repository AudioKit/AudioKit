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
        return "\(parameterString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        parameterString = operationString
    }
    public init(value: Float) {
        parameterString = "\(value)"
    }
    
    public func floor() -> AKParameter {
        return AKParameter("\(self)floor")
    }
}

public func floor(parameter: AKParameter) -> AKParameter {
    return parameter.floor()
}

public struct AKStereoParameter: CustomStringConvertible {
    var parameterString = ""
    public var description: String {
        return "\(parameterString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    init(_ operationString: String) {
        parameterString = operationString
    }
}

public func + (left: AKParameter, right: AKParameter) -> AKParameter {
    return AKP.add(left, right)
}

public func + (left: AKParameter, right: Float) -> AKParameter {
    return AKP.add(left, right.ak)
}

public func + (left: Float, right: AKParameter) -> AKParameter {
    return AKP.add(left.ak, right)
}

public func * (left: AKParameter, right: AKParameter) -> AKParameter {
    return AKP.multiply(left, right)
}

public func * (left: AKParameter, right: Float) -> AKParameter {
    return AKP.multiply(left, right.ak)
}

public func * (left: Float, right: AKParameter) -> AKParameter {
    return AKP.multiply(left.ak, right)
}

public func - (left: AKParameter, right: AKParameter) -> AKParameter {
    return AKP.subtract(left, right)
}

public func - (left: AKParameter, right: Float) -> AKParameter {
    return AKP.subtract(left, right.ak)
}

public func - (left: Float, right: AKParameter) -> AKParameter {
    return AKP.subtract(left.ak, right)
}

public func / (left: AKParameter, right: AKParameter) -> AKParameter {
    return AKP.divide(left, right)
}

public func / (left: AKParameter, right: Float) -> AKParameter {
    return AKP.divide(left, right.ak)
}

public func / (left: Float, right: AKParameter) -> AKParameter {
    return AKP.divide(left.ak, right)
}

public struct AKP {
        
    public static let input = AKParameter("0 p 1 p")

    public enum SinePreset {
        case Fast
        case Slow
    }
    public static func sine(frequency frequency: AKParameter = 440.ak,
        amplitude: AKParameter = 1.ak) -> AKParameter {
            return AKParameter("\(frequency)\(amplitude)sine")
    }
    public static func sine(preset preset: SinePreset) -> AKParameter {
        switch preset {
        case .Fast:
            return sine(frequency: 10.ak, amplitude: 1.ak)
        case .Slow:
            return sine(frequency: 0.1.ak, amplitude: 1.ak)
        }
    }
    
    public static func multiply(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
        return AKParameter("\(parameter1)\(parameter2)*")
    }
    public static func add(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
        return AKParameter("\(parameter1)\(parameter2)+")
    }
    public static func subtract(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
        return AKParameter("\(parameter1)\(parameter2)-")
    }
    public static func divide(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
        return AKParameter("\(parameter1)\(parameter2)/")
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

extension AKP {
    public static func effect(input: AKNode, operation: AKParameter) -> AKCustomEffect {
        // Add "swap drop" to discard the right channel input, and then
        // add "dup" to copy the left channel output to the right channel output
        return AKCustomEffect(input, sporth:"\(operation) swap drop dup")
    }
    public static func effect(input: AKNode, operation: AKStereoParameter) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(operation)")
    }
    
    public static func stereoEffect(input: AKNode, leftOperation: AKParameter, rightOperation: AKParameter) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(leftOperation) swap \(rightOperation) swap")
    }
    
    public static func generator(operation: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(operation) dup")
    }
    
    public static func generator(left: AKParameter, _ right: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(left) \(right)")
    }
}