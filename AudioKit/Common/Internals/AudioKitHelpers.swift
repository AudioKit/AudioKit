//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

public typealias MIDINoteNumber = Int
public typealias MIDIVelocity = Int
public typealias MIDIChannel = Int

extension Collection where IndexDistance == Int {
    /// Return a random element from the collection
    public func randomElement() -> Iterator.Element {
        let offset = Int(arc4random_uniform(UInt32(count.toIntMax())))
        return self[index(startIndex, offsetBy: offset)]
    }
}

/// Helper function to convert codes for Audio Units
/// - parameter string: Four character string to convert
public func fourCC(_ string: String) -> UInt32 {
    let utf8 = string.utf8
    precondition(utf8.count == 4, "Must be a 4 char string")
    var out: UInt32 = 0
    for char in utf8 {
        out <<= 8
        out |= UInt32(char)
    }
    return out
}

/// Random double between bounds
///
/// - Parameters:
///   - minimum: Lower bound of randomization
///   - maximum: Upper bound of randomization
///
public func random(_ minimum: Double, _ maximum: Double) -> Double {
    let precision = 1000000
    let width = maximum - minimum

    return Double(arc4random_uniform(UInt32(precision))) / Double(precision) * width + minimum
}

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension Double {

    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the source range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the source range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func normalized(
        minimum: Double,
                maximum: Double,
                taper: Double) -> Double {

        if taper > 0 {
            // algebraic taper
            return pow(((self - minimum) / (maximum - minimum)), (1.0 / taper))
        } else {
            // exponential taper
            return minimum * exp(log(maximum / minimum) * self)
        }
    }

    /// Convert a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the source range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the source range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func normalize(_ minimum: Double, maximum: Double, taper: Double) {
        self = self.normalized(minimum: minimum, maximum: maximum, taper: taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the target range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the target range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func denormalized(minimum: Double,
                             maximum: Double,
                             taper: Double) -> Double {
        
        // Avoiding division by zero in this trivial case
        if maximum - minimum < 0.00001 {
            return minimum
        }
        
        if taper > 0 {
            // algebraic taper
            return minimum + (maximum - minimum) * pow(self, taper)
        } else {
            // exponential taper
            var adjustedMinimum: Double = 0.0
            var adjustedMaximum: Double = 0.0
            if minimum == 0 { adjustedMinimum = 0.00000000001 }
            if maximum == 0 { adjustedMaximum = 0.00000000001 }

            return log(self / adjustedMinimum) / log(adjustedMaximum / adjustedMinimum)
        }
    }

    /// Convert a value on [0, 1] to a [min, max] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the target range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the target range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public mutating func denormalize(minimum: Double, maximum: Double, taper: Double) {
        self = self.denormalized(minimum: minimum, maximum: maximum, taper: taper)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {

    /// Calculate frequency from a MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return pow(2.0, (Double(self) - 69.0) / 12.0) * aRef
    }
}

/// Extension to Double to get the frequency from a MIDI Note Number
extension Double {

    /// Calculate frequency from a floating point MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }

}

extension Int {

    /// Calculate MIDI Note Number from a frequency in Hz
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func frequencyToMIDINote(_ aRef: Double = 440.0) -> Double {
        return 69 + 12 * log2(Double(self)/aRef)
    }
}

/// Extension to Double to get the frequency from a MIDI Note Number
extension Double {

    /// Calculate MIDI Note Number from a frequency in Hz
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func frequencyToMIDINote(_ aRef: Double = 440.0) -> Double {
        return 69 + 12 * log2(self/aRef)
    }
}

extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
	/// Initialize array with zeroes, ~10x faster than append for array of size 4096
	///
	/// - parameter count: Number of elements in the array
	///

    public init(zeroes count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension ClosedRange {
    /// Clamp value to the range
    ///
    /// - parameter value: Value to clamp
    ///
    public func clamp(_ value: Bound) -> Bound {
        return min(max(value, lowerBound), upperBound)
    }
}

extension Sequence where Iterator.Element: Hashable {
    internal var unique: [Iterator.Element] {
        var s: Set<Iterator.Element> = []
        return filter {
            s.insert($0).inserted
        }
    }
}

internal func AudioUnitGetParameter(_ unit: AudioUnit, param: AudioUnitParameterID) -> Double {
    var val: AudioUnitParameterValue = 0
    AudioUnitGetParameter(unit, param, kAudioUnitScope_Global, 0, &val)
    return Double(val)
}

internal func AudioUnitSetParameter(_ unit: AudioUnit, param: AudioUnitParameterID, to value: Double) {
    AudioUnitSetParameter(unit, param, kAudioUnitScope_Global, 0, AudioUnitParameterValue(value), 0)
}

internal struct AUWrapper {
    let au: AudioUnit

    init(au: AudioUnit) {
        self.au = au
    }

    subscript (param: AudioUnitParameterID) -> Double {
        get {
            return AudioUnitGetParameter(au, param: param)
        }
        set {
            AudioUnitSetParameter(au, param: param, to: newValue)
        }
    }
}


