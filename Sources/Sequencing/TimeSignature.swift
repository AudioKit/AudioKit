// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Time Signature
public struct TimeSignature: CustomStringConvertible, Equatable {
    /// Denominator of the time signature
    public enum TimeSignatureBottomValue: UInt8 {
        /// According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case two = 1
        /// According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case four = 2
        /// According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case eight = 3
        /// According to MIDI spec, second byte is log base 2 of time signature 'denominator'
        case sixteen = 4
    }

    /// Numerator of the time signature
    public var topValue: UInt8 = 4
    /// Denominator of the time signature
    public var bottomValue: TimeSignatureBottomValue = .four

    /// Initialize the time signature
    /// - Parameters:
    ///   - topValue: Numerator
    ///   - bottomValue: Denominator
    public init(topValue: UInt8 = 4, bottomValue: TimeSignatureBottomValue = .four) {
        self.topValue = topValue
        self.bottomValue = bottomValue
    }

    /// Time signature tuple
    public var readableTimeSignature: (Int, Int) {
        return (Int(topValue), Int(pow(2.0, Double(bottomValue.rawValue))))
    }

    /// Pretty printout
    public var description: String {
        return "\(readableTimeSignature.0)/\(readableTimeSignature.1)"
    }
}
