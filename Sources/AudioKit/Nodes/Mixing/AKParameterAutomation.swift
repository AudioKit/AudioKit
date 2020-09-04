// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

extension AKParameterAutomationPoint: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.targetValue == rhs.targetValue
            && lhs.startTime == rhs.startTime
            && lhs.rampDuration == rhs.rampDuration
    }
}
