// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public struct AKTimeSignature: CustomStringConvertible, Equatable {
    public enum TimeSignatureBottomValue: UInt8 {
        // According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case two = 1
        case four = 2
        case eight = 3
        case sixteen = 4
    }

    public var topValue: UInt8 = 4
    public var bottomValue: TimeSignatureBottomValue = .four

    public init(topValue: UInt8 = 4, bottomValue: TimeSignatureBottomValue = .four) {
        self.topValue = topValue
        self.bottomValue = bottomValue
    }

    public var readableTimeSignature: (Int, Int) {
        return (Int(topValue), Int(pow(2.0, Double(bottomValue.rawValue))))
    }

    public var description: String {
        return "\(readableTimeSignature.0)/\(readableTimeSignature.1)"
    }
}
