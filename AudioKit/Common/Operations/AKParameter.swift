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
        parameterString = "\(value)"
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
        return AKCustomEffect(input, sporth:"\(operation)")
    }
    

    public static func generator(operation: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(operation) dup")
    }
    
    public static func generator(left: AKParameter, _ right: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(left) \(right)")
    }
}