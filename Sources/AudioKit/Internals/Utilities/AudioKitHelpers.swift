// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import AVFoundation
import CoreAudio

/// Normally set in AVFoundation or AudioToolbox,
/// we create it here so users don't have to import those frameworks
public typealias AUValue = Float

/// MIDI Type Alias making it clear that you're working with MIDI
public typealias MIDIByte = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
public typealias MIDIWord = UInt16
/// MIDI Type Alias making it clear that you're working with MIDI
public typealias MIDINoteNumber = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
public typealias MIDIVelocity = UInt8
/// MIDI Type Alias making it clear that you're working with MIDI
public typealias MIDIChannel = UInt8

/// Sample type alias making it clear when you're workin with samples
public typealias SampleIndex = UInt32

/// Note on shortcut
public let noteOnByte: MIDIByte = 0x90
/// Note off shortcut
public let noteOffByte: MIDIByte = 0x80

/// 2D array of stereo audio data
public typealias FloatChannelData = [[Float]]

/// Callback function that can be called from C
public typealias CVoidCallback = @convention(block) () -> Void

/// Callback function that can be called from C
public typealias CMIDICallback = @convention(block) (MIDIByte, MIDIByte, MIDIByte) -> Void

extension AudioUnitParameterOptions {
    /// Default options
    public static let `default`: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
}

extension CGRect {
    /// Initialize with a size
    /// - Parameter size: size to create the CGRect with
    public init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    /// Initialize with width and height
    /// - Parameters:
    ///   - width: Width of rectangle
    ///   - height: Height of rectangle
    public init(width: CGFloat, height: CGFloat) {
        self.init(origin: .zero, size: CGSize(width: width, height: height))
    }

    /// Initialize with width and height
    /// - Parameters:
    ///   - width: Width of rectangle
    ///   - height: Height of rectangle
    public init(width: Int, height: Int) {
        self.init(width: CGFloat(width), height: CGFloat(height))
    }
}

/// Helper function to convert codes for Audio Units
/// - parameter string: Four character string to convert
public func fourCC(_ string: String) -> UInt32 {
    let utf8 = string.utf8
    precondition(utf8.count == 4, "Must be a 4 character string")
    var out: UInt32 = 0
    for char in utf8 {
        out <<= 8
        out |= UInt32(char)
    }
    return out
}

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension AUValue {
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Source range (cannot include zero if taper is not positive)
    ///   - taper:Must be a postive number, taper = 1 is linear
    ///
    public func normalized(from range: ClosedRange<AUValue>, taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return powf((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Target range (cannot contain zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func denormalized(to range: ClosedRange<AUValue>, taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * powf(self, taper)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
extension Int {
    /// Calculate frequency from a MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    public func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).midiNoteToFrequency(aRef)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
extension MIDIByte {
    /// Calculate frequency from a MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    public func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).midiNoteToFrequency(aRef)
    }
}

/// Extension to get the frequency from a MIDI Note Number
extension AUValue {
    /// Calculate frequency from a floating point MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    public func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }
}

extension Int {
    /// Calculate MIDI Note Number from a frequency in Hz
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    public func frequencyToMIDINote(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).frequencyToMIDINote(aRef)
    }
}

/// Extension to get the frequency from a MIDI Note Number
extension AUValue {
    /// Calculate MIDI Note Number from a frequency in Hz
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    public func frequencyToMIDINote(_ aRef: AUValue = 440.0) -> AUValue {
        return 69 + 12 * log2(self / aRef)
    }
}

extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
    /// Initialize array with zeros, ~10x faster than append for array of size 4096
    /// - parameter count: Number of elements in the array
    public init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension ClosedRange {
    /// Clamp value to the range
    /// - parameter value: Value to clamp
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
internal func AudioUnitGetParameter(_ unit: AudioUnit, param: AudioUnitParameterID) -> AUValue {
    var val: AudioUnitParameterValue = 0
    AudioUnitGetParameter(unit, param, kAudioUnitScope_Global, 0, &val)
    return val
}

@inline(__always)
internal func AudioUnitSetParameter(_ unit: AudioUnit, param: AudioUnitParameterID, to value: AUValue) {
    AudioUnitSetParameter(unit, param, kAudioUnitScope_Global, 0, AudioUnitParameterValue(value), 0)
}

/// Adding subscript
extension AVAudioUnit {
    subscript(param: AudioUnitParameterID) -> AUValue {
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

    subscript(param: AudioUnitParameterID) -> AUValue {
        get {
            return self.avAudioUnit[param]
        }
        set {
            self.avAudioUnit[param] = newValue
        }
    }
}

extension AVAudioNode {
    func inputConnections() -> [AVAudioConnectionPoint] {
        return (0 ..< numberOfInputs).compactMap { engine?.inputConnectionPoint(for: self, inputBus: $0) }
    }
}

public extension AUParameter {
    /// Initialize with all specification
    /// - Parameters:
    ///   - identifier: ID String
    ///   - name: Unique name
    ///   - address: Parameter address
    ///   - range: Range of valid values
    ///   - unit: Physical units
    ///   - flags: Parameter options
    @nonobjc
    convenience init(identifier: String,
                     name: String,
                     address: AUParameterAddress,
                     range: ClosedRange<AUValue>,
                     unit: AudioUnitParameterUnit,
                     flags: AudioUnitParameterOptions) {
        self.init(identifier: identifier,
                  name: name,
                  address: address,
                  min: range.lowerBound,
                  max: range.upperBound,
                  unit: unit,
                  flags: flags)
    }
}

/// Anything that can hold a value (strings, arrays, etc)
public protocol Occupiable {
    /// Contains elements
    var isEmpty: Bool { get }
    /// Contains no elements
    var isNotEmpty: Bool { get }
}

// Give a default implementation of isNotEmpty, so conformance only requires one implementation
extension Occupiable {
    /// Contains no elements
    public var isNotEmpty: Bool {
        return ❗️isEmpty
    }
}

extension String: Occupiable {}

// I can't think of a way to combine these collection types. Suggestions welcome.
extension Array: Occupiable {}
extension Dictionary: Occupiable {}
extension Set: Occupiable {}

#if !os(macOS)
extension AVAudioSession.CategoryOptions: Occupiable {}
#endif

prefix operator ❗️

/// Negative logic can be confusing, so we draw special attention to those cases
public prefix func ❗️(a: Bool) -> Bool {
    return !a
}
