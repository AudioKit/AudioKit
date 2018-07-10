//
//  AudioKitHelpers.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioToolbox
import CoreAudio

public typealias MIDIByte = UInt8
public typealias MIDIWord = UInt16
public typealias MIDINoteNumber = UInt8
public typealias MIDIVelocity = UInt8
public typealias MIDIChannel = UInt8

/// A Sample type, just a UInt32
public typealias Sample = UInt32

/// Callback function that can be called from C
public typealias AKCCallback = @convention(block) () -> Void

extension Collection {
    /// Return a random element from the collection
    public var randomIndex: Index {
        let offset = Int(arc4random_uniform(UInt32(Int64(count))))
        return index(startIndex, offsetBy: offset)
    }

    /// Retrieve a random element from the collection
    public func randomElement() -> Iterator.Element {
        return self[randomIndex]
    }
}

/// Helper function to convert codes for Audio Units
/// - parameter string: Four character string to convert
///
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

/// Wrapper for printing out status messages to the console,
/// eventually it could be expanded with log levels
/// - items: Zero or more items to print.
///
@inline(__always)
public func AKLog(fullname: String = #function, file: String = #file, line: Int = #line, _ items: Any...) {
    if AKSettings.enableLogging {
        let fileName = (file as NSString).lastPathComponent
        var content = ""
        for i in 0 ..< items.count {
            content += String(describing: items[i])
            if i < items.count - 1 {
                content += " "
            }
        }
        Swift.print("\(fileName):\(fullname):\(line):\(content)")
    }
}

/// Random double between bounds
///
/// - Parameters:
///   - minimum: Lower bound of randomization
///   - maximum: Upper bound of randomization
///
@available(*, deprecated, renamed: "random(in:)")
public func random(_ minimum: Double, _ maximum: Double) -> Double {
    return random(in: minimum ... maximum)
}

/// Random double in range
///
/// - parameter in: Range of randomization
///
public func random(in range: ClosedRange<Double>) -> Double {
    let precision = 1_000_000
    let width = range.upperBound - range.lowerBound

    return Double(arc4random_uniform(UInt32(precision))) / Double(precision) * width + range.lowerBound
}

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension Double {

    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Source range (cannot include zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func normalized(from range: ClosedRange<Double>, taper: Double = 1) -> Double {
        assert(!(range.contains(0.0) && taper < 0), "Cannot have negative taper with a range containing zero.")

        if taper > 0 {
            // algebraic taper
            return pow(((self - range.lowerBound ) / (range.upperBound - range.lowerBound)), (1.0 / taper))
        } else {
            // exponential taper
            return range.lowerBound * exp(log(range.upperBound / range.lowerBound) * self)
        }
    }

    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the source range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the source range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    @available(*, deprecated, renamed: "normalized(from:taper:)")
    public func normalized(minimum: Double, maximum: Double, taper: Double = 1) -> Double {
        return self.normalized(from: minimum...maximum, taper: taper)
    }

    /// Convert a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the source range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the source range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    @available(*, deprecated, renamed: "normalize(from:taper:)")
    public mutating func normalize(minimum: Double, maximum: Double, taper: Double = 1) {
        self = self.normalized(from: minimum ... maximum, taper: taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Target range (cannot contain zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func denormalized(to range: ClosedRange<Double>, taper: Double = 1) -> Double {

        assert(!(range.contains(0.0) && taper < 0), "Cannot have negative taper with a range containing zero.")

        // Avoiding division by zero in this trivial case
        if range.upperBound - range.lowerBound < 0.000_01 {
            return range.lowerBound
        }

        if taper > 0 {
            // algebraic taper
            return range.lowerBound + (range.upperBound - range.lowerBound) * pow(self, taper)
        } else {
            // exponential taper
            var adjustedMinimum: Double = 0.0
            var adjustedMaximum: Double = 0.0
            if range.lowerBound == 0 { adjustedMinimum = 0.000_000_000_01 }
            if range.upperBound == 0 { adjustedMaximum = 0.000_000_000_01 }

            return log(self / adjustedMinimum) / log(adjustedMaximum / adjustedMinimum)
        }
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the target range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the target range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    @available(*, deprecated, renamed: "denormalized(to:taper:)")
    public func denormalized(minimum: Double, maximum: Double, taper: Double = 1) -> Double {
        return self.denormalized(to: minimum ... maximum, taper: taper)
    }

    /// Convert a value on [0, 1] to a [min, max] range, according to a taper
    ///
    /// - Parameters:
    ///   - minimum: Minimum of the target range (cannot be zero if taper is not positive)
    ///   - maximum: Maximum of the target range
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    @available(*, deprecated, renamed: "denormalize(to:taper:)")
    public mutating func denormalize(minimum: Double, maximum: Double, taper: Double = 1) {
        self = self.denormalized(to: minimum ... maximum, taper: taper)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {

    /// Calculate frequency from a MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return Double(self).midiNoteToFrequency(aRef)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
extension UInt8 {

    /// Calculate frequency from a MIDI Note Number
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func midiNoteToFrequency(_ aRef: Double = 440.0) -> Double {
        return Double(self).midiNoteToFrequency(aRef)
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
        return Double(self).frequencyToMIDINote(aRef)
    }
}

/// Extension to Double to get the frequency from a MIDI Note Number
extension Double {

    /// Calculate MIDI Note Number from a frequency in Hz
    ///
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    ///
    public func frequencyToMIDINote(_ aRef: Double = 440.0) -> Double {
        return 69 + 12 * log2(self / aRef)
    }
}

extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
	/// Initialize array with zeros, ~10x faster than append for array of size 4096
	///
	/// - parameter count: Number of elements in the array
	///

    public init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension ClosedRange {
    /// Clamp value to the range
    ///
    /// - parameter value: Value to clamp
    ///
    public func clamp(_ value: Bound) -> Bound {
        return Swift.min(Swift.max(value, lowerBound), upperBound)
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

@inline(__always)
internal func AudioUnitGetParameter(_ unit: AudioUnit, param: AudioUnitParameterID) -> Double {
    var val: AudioUnitParameterValue = 0
    AudioUnitGetParameter(unit, param, kAudioUnitScope_Global, 0, &val)
    return Double(val)
}

@inline(__always)
internal func AudioUnitSetParameter(_ unit: AudioUnit, param: AudioUnitParameterID, to value: Double) {
    AudioUnitSetParameter(unit, param, kAudioUnitScope_Global, 0, AudioUnitParameterValue(value), 0)
}

/// Adding subscript
extension AVAudioUnit {
    subscript (param: AudioUnitParameterID) -> Double {
        get {
              return AudioUnitGetParameter(audioUnit, param: param)
        }
        set {
              AudioUnitSetParameter(audioUnit, param: param, to: newValue)
        }
    }
}

internal struct AUWrapper {
    private let avAudioUnit: AVAudioUnit

    init(_ avAudioUnit: AVAudioUnit) {
        self.avAudioUnit = avAudioUnit
    }

    subscript (param: AudioUnitParameterID) -> Double {
        get {
            return avAudioUnit[param]
        }
        set {
            avAudioUnit[param] = newValue
        }
    }
}

/// Adding instantiation with component and callback
public extension AVAudioUnit {
    public class func _instantiate(with component: AudioComponentDescription, callback: @escaping (AVAudioUnit) -> Void) {
        AVAudioUnit.instantiate(with: component, options: []) { avAudioUnit, _ in
            avAudioUnit.map {
                AudioKit.engine.attach($0)
                callback($0)
            }
        }
    }
}

extension AUParameter {
    @nonobjc
    convenience init(_ identifier: String,
                     name: String,
                     address: AUParameterAddress,
                     range: ClosedRange<AUValue>,
                     unit: AudioUnitParameterUnit,
                     value: AUValue = 0) {
        self.init(identifier,
                  name: name,
                  address: address,
                  min: range.lowerBound,
                  max: range.upperBound,
                  unit: unit)
        self.value = value
    }
}

/// Adding instantiate with callback
extension AudioComponentDescription {
    func instantiate(callback: @escaping (AVAudioUnit) -> Void) {
        AVAudioUnit._instantiate(with: self) {
            callback($0)
        }
    }
}

// Anything that can hold a value (strings, arrays, etc)
public protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

// Give a default implementation of isNotEmpty, so conformance only requires one implementation
extension Occupiable {
    public var isNotEmpty: Bool {
        return ❗️isEmpty
    }
}

extension String: Occupiable { }

// I can't think of a way to combine these collection types. Suggestions welcome.
extension Array: Occupiable { }
extension Dictionary: Occupiable { }
extension Set: Occupiable { }

#if !os(macOS)
extension AVAudioSessionCategoryOptions: Occupiable { }
#endif

prefix operator ❗️

/// Negative logic can be confusing, so we draw special attention to those cases
prefix public func ❗️(a: Bool) -> Bool {
    return !a
}
