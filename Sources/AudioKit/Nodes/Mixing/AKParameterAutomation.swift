// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public extension AKParameterAutomationPoint {
    init(targetValue: AUValue,
         startTime: Float,
         rampDuration: Float) {
        self.init(targetValue: targetValue,
                  startTime: startTime,
                  rampDuration: rampDuration,
                  rampTaper: 1,
                  rampSkew: 0)
    }

    func isLinear() -> Bool {
        return rampTaper == 1.0 && rampSkew == 0.0
    }
}

extension AKParameterAutomationPoint: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.targetValue == rhs.targetValue
            && lhs.startTime == rhs.startTime
            && lhs.rampDuration == rhs.rampDuration
            && lhs.rampTaper == rhs.rampTaper
            && lhs.rampSkew == rhs.rampSkew
    }
}
