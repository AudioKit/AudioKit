// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public extension ParameterAutomationPoint {
    /// Initialize with value, time, and duration
    /// - Parameters:
    ///   - targetValue: Target value
    ///   - startTime: Start time
    ///   - rampDuration: Ramp duration
    init(targetValue: AUValue,
         startTime: Float,
         rampDuration: Float) {
        self.init(targetValue: targetValue,
                  startTime: startTime,
                  rampDuration: rampDuration,
                  rampTaper: 1,
                  rampSkew: 0)
    }

    /// Check for linearity
    /// - Returns: True if linear
    func isLinear() -> Bool {
        return rampTaper == 1.0 && rampSkew == 0.0
    }
}

extension ParameterAutomationPoint: Equatable {
    /// Equality check
    /// - Parameters:
    ///   - lhs: Left hand side
    ///   - rhs: Right hand side
    /// - Returns: True if equal
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.targetValue == rhs.targetValue
            && lhs.startTime == rhs.startTime
            && lhs.rampDuration == rhs.rampDuration
            && lhs.rampTaper == rhs.rampTaper
            && lhs.rampSkew == rhs.rampSkew
    }
}
