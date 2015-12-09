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
    public func abs() -> AKParameter {
        return AKParameter("\(self)abs")
    }
    public func floor() -> AKParameter {
        return AKParameter("\(self)floor")
    }
    public func fract() -> AKParameter {
        return AKParameter("\(self)frac")
    }
    public func log() -> AKParameter {
        return AKParameter("\(self)log")
    }
    public func log10() -> AKParameter {
        return AKParameter("\(self)log10")
    }
    public func round() -> AKParameter {
        return AKParameter("\(self)round")
    }
}

public func abs(parameter: AKParameter) -> AKParameter {
    return parameter.abs()
}

public func floor(parameter: AKParameter) -> AKParameter {
    return parameter.floor()
}

public func fract(parameter: AKParameter) -> AKParameter {
    return parameter.fract()
}

public func log(parameter: AKParameter) -> AKParameter {
    return parameter.log()
}

public func log10(parameter: AKParameter) -> AKParameter {
    return parameter.log10()
}

public func round(parameter: AKParameter) -> AKParameter {
    return parameter.round()
}



public func max(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
    return AKParameter("\(parameter1)\(parameter2)max")
}
public func min(parameter1: AKParameter, _ parameter2: AKParameter) -> AKParameter {
    return AKParameter("\(parameter1)\(parameter2)min")
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

}