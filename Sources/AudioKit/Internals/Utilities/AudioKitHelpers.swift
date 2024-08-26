// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AudioToolbox
import AVFoundation
import CoreAudio

// TODO: write unit tests.

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

/// Sample type alias making it clear when you're working with samples
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

public extension AudioUnitParameterOptions {
    /// Default options
    static let `default`: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
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
public extension AUValue {
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Source range (cannot include zero if taper is not positive)
    ///   - taper:Must be a positive number, taper = 1 is linear
    ///
    func normalized(from range: ClosedRange<AUValue>, taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return powf((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Target range (cannot contain zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    func denormalized(to range: ClosedRange<AUValue>, taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * powf(self, taper)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
public extension Int {
    /// Calculate frequency from a MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).midiNoteToFrequency(aRef)
    }
}

/// Extension to Int to calculate frequency from a MIDI Note Number
public extension MIDIByte {
    /// Calculate frequency from a MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).midiNoteToFrequency(aRef)
    }
}

/// Extension to get the frequency from a MIDI Note Number
public extension AUValue {
    /// Calculate frequency from a floating point MIDI Note Number
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    func midiNoteToFrequency(_ aRef: AUValue = 440.0) -> AUValue {
        return pow(2.0, (self - 69.0) / 12.0) * aRef
    }
}

public extension Int {
    /// Calculate MIDI Note Number from a frequency in Hz
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    func frequencyToMIDINote(_ aRef: AUValue = 440.0) -> AUValue {
        return AUValue(self).frequencyToMIDINote(aRef)
    }
}

/// Extension to get the frequency from a MIDI Note Number
public extension AUValue {
    /// Calculate MIDI Note Number from a frequency in Hz
    /// - parameter aRef: Reference frequency of A Note (Default: 440Hz)
    func frequencyToMIDINote(_ aRef: AUValue = 440.0) -> AUValue {
        return 69 + 12 * log2(self / aRef)
    }
}

public extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
    /// Initialize array with zeros, ~10x faster than append for array of size 4096
    /// - parameter count: Number of elements in the array
    init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var s: Set<Iterator.Element> = []
        return filter { s.insert($0).inserted }
    }
}

@inline(__always)
internal func AudioUnitGetParameter(_ unit: AudioUnit, param: AudioUnitParameterID) -> AUValue {
    var val: AudioUnitParameterValue = 0
    let status = AudioUnitGetParameter(unit, param, kAudioUnitScope_Global, 0, &val)
    CheckError(status)
    return val
}

@inline(__always)
internal func AudioUnitSetParameter(_ unit: AudioUnit, param: AudioUnitParameterID, to value: AUValue) {
    let status = AudioUnitSetParameter(unit, param, kAudioUnitScope_Global, 0, AudioUnitParameterValue(value), 0)
    CheckError(status)
}

extension AVAudioNode {
    public var inputCount: Int { numberOfInputs }

    func inputConnections() -> [AVAudioConnectionPoint] {
        return (0 ..< inputCount).compactMap { engine?.inputConnectionPoint(for: self, inputBus: $0) }
    }
}

public extension AUParameterTree {
    class func createParameter(identifier: String,
                               name: String,
                               address: AUParameterAddress,
                               range: ClosedRange<AUValue>,
                               unit: AudioUnitParameterUnit,
                               flags: AudioUnitParameterOptions) -> AUParameter
    {
        AUParameterTree.createParameter(withIdentifier: identifier,
                                        name: name,
                                        address: address,
                                        min: range.lowerBound,
                                        max: range.upperBound,
                                        unit: unit,
                                        unitName: nil,
                                        flags: flags,
                                        valueStrings: nil,
                                        dependentParameters: nil)
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
public extension Occupiable {
    /// Contains no elements
    var isNotEmpty: Bool {
        return !isEmpty
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

public extension Sequence where Self.Element: Equatable {
    /// Easier to read alternative to !contains
    @inline(__always)
    func doesNotContain(_ member: Element) -> Bool {
        return !contains(member)
    }
}

public extension String {
    /// Useful fo converting camel case enums to UI strings
    func titleCase() -> String {
        return replacingOccurrences(of: "([A-Z])",
                                    with: " $1",
                                    options: .regularExpression,
                                    range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}

public extension Double {
    /// Map the value to a new range
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mapped(from source: ClosedRange<Double> = 0 ... 1.0, to target: ClosedRange<Double> = 0 ... 1.0) -> Double {
        return ((self - source.lowerBound) / (source.upperBound - source.lowerBound)) * (target.upperBound - target.lowerBound) + target.lowerBound
    }

    /// Returns false if the value is not positive
    var isValidSampleRate: Bool {
        // Could expand on this to check the valid sample rate range for the device
        // (typically from 8000 through 48000 hertz.)
        return self > 0
    }
}

public extension CGFloat {
    /// Map the value to a new range
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mapped(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return ((self - source.lowerBound) / (source.upperBound - source.lowerBound)) * (target.upperBound - target.lowerBound) + target.lowerBound
    }

    /// Map the value to a new inverted range
    /// Return a value on [from.lowerBound,from.upperBound] to the inverse of a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedInverted(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return target.upperBound - mapped(from: source, to: target) + target.lowerBound
    }

    /// Map the value to a new range at a base-10 logarithmic scaling
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedLog10(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        let logN = log10(self)
        let logStart1 = log10(source.lowerBound)
        let logStop1 = log10(source.upperBound)
        let result = ((logN - logStart1) / (logStop1 - logStart1)) * (target.upperBound - target.lowerBound) + target.lowerBound
        if result.isNaN {
            return 0.0
        } else {
            return ((logN - logStart1) / (logStop1 - logStart1)) * (target.upperBound - target.lowerBound) + target.lowerBound
        }
    }

    /// Map the value to a new range at a base e^log(n) scaling
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range (Default: 0...1.0)
    ///   - to target: Desired range (Default: 0...1.0)
    func mappedExp(from source: ClosedRange<CGFloat> = 0 ... 1.0, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        let logStart2 = log(target.lowerBound)
        let logStop2 = log(target.upperBound)
        let scale = (logStop2 - logStart2) / (source.upperBound - source.lowerBound)
        return exp(logStart2 + scale * (self - source.lowerBound))
    }
}


public extension Int {
    /// Map the value to a new range
    /// Return a value on [from.lowerBound,from.upperBound] to a [to.lowerBound, to.upperBound] range
    ///
    /// - Parameters:
    ///   - from source: Current range
    ///   - to target: Desired range (Default: 0...1.0)
    func mapped(from source: ClosedRange<Int>, to target: ClosedRange<CGFloat> = 0 ... 1.0) -> CGFloat {
        return (CGFloat(self - source.lowerBound) / CGFloat(source.upperBound - source.lowerBound)) * (target.upperBound - target.lowerBound) + target.lowerBound
    }
}

public extension Array where Element == Float {
    /// Takes an array of floating point values and down samples it to have a lesser number of samples
    /// Returns an array of downsampled floating point values
    ///
    /// Parameters:
    ///   - sampleCount: the number of samples we will downsample the array to
    func downSample(to sampleCount: Int = 128) -> [Element] {
        let inputSampleCount = count
        let inputLength = vDSP_Length(inputSampleCount)

        let filterLength: vDSP_Length = 2
        let filter = [Float](repeating: 1 / Float(filterLength), count: Int(filterLength))

        let decimationFactor = inputSampleCount / sampleCount
        let outputLength = vDSP_Length((inputLength - filterLength) / vDSP_Length(decimationFactor))

        var outputFloats = [Float](repeating: 0, count: Int(outputLength))
        vDSP_desamp(self,
                    decimationFactor,
                    filter,
                    &outputFloats,
                    outputLength,
                    filterLength)
        return outputFloats
    }
}

/// Load the audio information from a url to an audio file
/// Returns the floating point array of values, sample rate, and frame count
///
/// - Parameters:
///   - audioURL: Url to audio file
public func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int)? {
    do {
        let file = try AVAudioFile(forReading: audioURL)
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                        sampleRate: file.fileFormat.sampleRate,
                                        channels: file.fileFormat.channelCount, interleaved: false)
        if let format = audioFormat {
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            do {
                if let buffer = buf {
                    try file.read(into: buffer)
                    let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0],
                                                               count: Int(buffer.frameLength)))
                    return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
                }
            } catch {
                Log("Error in Load Audio Signal: could not read audio file into buffer", type: .error)
            }
        }
    } catch {
        Log("Error in Load Audio Signal: could not read url into audio file", type: .error)
    }
    return nil
}

public extension DSPSplitComplex {
    /// Initialize a DSPSplitComplex with repeating values for real and imaginary splits
    ///
    /// - Parameters:
    ///   - initialValue: value to set elements to
    ///   - count: number of real and number of imaginary elements
    init(repeating initialValue: Float, count: Int) {
        let real = [Float](repeating: initialValue, count: count)
        let realp = UnsafeMutablePointer<Float>.allocate(capacity: real.count)
        realp.assign(from: real, count: real.count)

        let imag = [Float](repeating: initialValue, count: count)
        let imagp = UnsafeMutablePointer<Float>.allocate(capacity: imag.count)
        imagp.assign(from: imag, count: imag.count)

        self.init(realp: realp, imagp: imagp)
    }

    /// Initialize a DSPSplitComplex with repeating values for real and imaginary splits
    ///
    /// - Parameters:
    ///   - repeatingReal: value to set real elements to
    ///   - repeatingImag: value to set imaginary elements to
    ///   - count: number of real and number of imaginary elements
    init(repeatingReal: Float, repeatingImag: Float, count: Int) {
        let real = [Float](repeating: repeatingReal, count: count)
        let realp = UnsafeMutablePointer<Float>.allocate(capacity: real.count)
        realp.assign(from: real, count: real.count)

        let imag = [Float](repeating: repeatingImag, count: count)
        let imagp = UnsafeMutablePointer<Float>.allocate(capacity: imag.count)
        imagp.assign(from: imag, count: imag.count)

        self.init(realp: realp, imagp: imagp)
    }

    func deallocate() {
        realp.deallocate()
        imagp.deallocate()
    }
}

public extension AVAudioTime {
    /// Returns an AVAudioTime set to sampleTime of zero at the default sample rate
    static func sampleTimeZero(sampleRate: Double = Settings.sampleRate) -> AVAudioTime {
        let sampleTime = AVAudioFramePosition(Double(0))
        return AVAudioTime(sampleTime: sampleTime, atRate: sampleRate)
    }
}

// Protocols used in AudioKit demos

/// Protocol prescribing that something has an audio "player"
public protocol ProcessesPlayerInput: HasAudioEngine {
    var player: AudioPlayer { get }
}

/// Protocol prescribing that something ahs an audio "engine"
public protocol HasAudioEngine {
    var engine: AudioEngine { get }
}

/// Basic start and stop functionality
public extension HasAudioEngine {
    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}
