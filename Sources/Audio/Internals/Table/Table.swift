// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Supported default table types
public enum TableType {
    /// Standard sine waveform
    case sine

    /// Standard triangle waveform
    case triangle

    /// Standard square waveform
    case square

    /// Standard sawtooth waveform
    case sawtooth

    /// Reversed sawtooth waveform
    case reverseSawtooth

    /// Sine wave from 0-1
    case positiveSine

    /// Triangle waveform from 0-1
    case positiveTriangle

    /// Square waveform from 0-1
    case positiveSquare

    /// Sawtooth waveform from 0-1
    case positiveSawtooth

    /// Reversed sawtooth waveform from 0-1
    case positiveReverseSawtooth

    /// Sine root + harmonics, with harmonic amplitudes as percentages of root amplitude
    case harmonic([Float])

    /// Zeros
    case zero

    /// Custom waveform
    case custom
}

/// A table of values accessible as a waveform or lookup mechanism
public class Table: MutableCollection {
    /// Index by an integer
    public typealias Index = Int
    /// Index distance, or count
    public typealias IndexDistance = Int
    /// This is a collection of floats
    public typealias Element = Float
    /// Subsequencable into slices
    public typealias SubSequence = ArraySlice<Element>

    // MARK: - Properties    /// Values stored in the table

    /// Array of elements
    public internal(set) var content = [Element]()

    /// Phase of the table
    public var phase: Float {
        didSet {
            phase = phase.clamped(to: 0 ... 1)
        }
    }

    /// Start point
    public var startIndex: Index {
        return content.startIndex
    }

    /// End point
    public var endIndex: Index {
        return content.endIndex
    }

    /// Number of elements
    public var count: IndexDistance {
        return content.count
    }

    /// Grab an element by index
    public subscript(index: Index) -> Element {
        get {
            return content[index]
        }
        set {
            content[index] = newValue
        }
    }

    /// Grab elements by range
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            return content[bounds]
        }
        set {
            content[bounds] = newValue
        }
    }

    /// Type of table
    var type: TableType

    // MARK: - Initialization

    /// Initialize and set up the default table
    ///
    /// - Parameters:
    ///   - type: TableType of the new table
    ///   - phase: Phase offset
    ///   - count: Size of the table (multiple of 2)
    ///
    public init(_ type: TableType = .sine,
                phase: Float = 0,
                count: IndexDistance = 4096)
    {
        self.type = type
        self.phase = phase
        content = [Element](zeros: count)

        switch type {
        case .sine:
            standardSineWave()
        case .sawtooth:
            standardSawtoothWave()
        case .triangle:
            standardTriangleWave()
        case .reverseSawtooth:
            standardReverseSawtoothWave()
        case .square:
            standardSquareWave()
        case .positiveSine:
            positiveSineWave()
        case .positiveSawtooth:
            positiveSawtoothWave()
        case .positiveTriangle:
            positiveTriangleWave()
        case .positiveReverseSawtooth:
            positiveReverseSawtoothWave()
        case .positiveSquare:
            positiveSquareWave()
        case let .harmonic(partialAmplitudes):
            harmonicWave(with: partialAmplitudes)
        case .zero:
            zero()
        case .custom:
            assertionFailure("use init(content:phase:count:) to initialize a custom waveform")
        }
    }

    /// Create table from an array of Element
    /// - Parameters:
    ///   - content: Array of elements
    ///   - phase: Offset
    public init(_ content: [Element], phase: Float = 0) {
        type = .custom
        self.phase = phase
        self.content = content
    }

    /// Create table from first channel of audio file
    /// - Parameter file: audio file to use as source data
    public convenience init?(file: AVAudioFile) {
        let size = Int(file.length)
        self.init(count: size)

        guard let data = file.toFloatChannelData() else { return nil }
        // Note: this is only taking the first channel of a file
        for i in 0 ..< size {
            self[i] = data[0][i]
        }
    }

    /// Create an Table with the contents of a pcmFormatFloat32 file.
    /// This method is intended for wavetables (i.e., 2048 or 4096 samples), not large audio files.
    /// Parameters:
    ///   - url: URL to the file
    public convenience init?(url: URL) throws {
        guard let sample = try AVAudioPCMBuffer(url: url),
              let leftChannel = sample.floatChannelData?[0] else { return nil }
        let length = Int(sample.frameLength)
        self.init(count: length)

        for i in 0 ..< length {
            let f = leftChannel[i]
            self[i] = f
        }
    }

    /// Offset of the phase
    public var phaseOffset: Int {
        @inline(__always)
        get {
            Int(phase * Float(count))
        }
    }

    /// Instantiate the table as a triangle wave
    func standardTriangleWave() {
        let slope = Float(4.0) / Float(count)
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = slope * Float((i + phaseOffset) % count) - 1.0
            } else {
                content[i] = slope * Float((-i - phaseOffset) % count) + 3.0
            }
        }
    }

    /// Instantiate the table as a square wave
    func standardSquareWave() {
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = -1.0
            } else {
                content[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    func standardSawtoothWave() {
        for i in indices {
            content[i] = Float(-1.0 + 2.0 * Float((i + phaseOffset) % count) / Float(count))
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    func standardReverseSawtoothWave() {
        for i in indices {
            content[i] = Float(1.0 - 2.0 * Float((i + phaseOffset) % count) / Float(count))
        }
    }

    /// Instantiate the table as a sine wave
    func standardSineWave() {
        for i in indices {
            content[i] = Float(sin(2 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
        }
    }

    /// Instantiate the table as root frequency with partials, where the partial amplitudes are
    /// a percentage of the root frequency amplitude
    func harmonicWave(with partialAmplitudes: [Float]) {
        for index in indices {
            var sum: Float = 0

            // Root
            sum = Float(sin(2 * 3.14_159_265 * Float(index + phaseOffset) / Float(count)))

            // Partials
            for ampIndex in 0 ..< partialAmplitudes.count {
                let partial =
                    Float(
                        sin(2 * 3.14_159_265 *
                            Float((index * (ampIndex + 2)) + phaseOffset)
                            / Float(count))
                    )
                sum += partial * partialAmplitudes[ampIndex]
            }

            content[index] = sum
        }
    }

    /// Instantiate the table as a triangle wave
    func positiveTriangleWave() {
        let slope = Float(2.0) / Float(count)
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = slope * Float((i + phaseOffset) % count)
            } else {
                content[i] = slope * Float((-i - phaseOffset) % count) + 2.0
            }
        }
    }

    /// Instantiate the table as a square wave
    func positiveSquareWave() {
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = 0.0
            } else {
                content[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    func positiveSawtoothWave() {
        for i in indices {
            content[i] = Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    func positiveReverseSawtoothWave() {
        for i in indices {
            content[i] = Float(1.0) - Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a sine wave
    func positiveSineWave() {
        for i in indices {
            content[i] = Float(0.5 + 0.5 * sin(2 * 3.14_159_265 * Float(i + phaseOffset) / Float(count)))
        }
    }

    /// Instantiate the table with zero values
    func zero() {
        for i in indices {
            content[i] = 0
        }
    }
}

extension Table: RandomAccessCollection {
    /// Indices for our elements
    public typealias Indices = Array<Element>.Indices

    /// Index before
    /// - Parameter i: current index
    @inline(__always)
    public func index(before i: Index) -> Index {
        return i - 1
    }

    /// Index after
    /// - Parameter i: current index
    @inline(__always)
    public func index(after i: Index) -> Index {
        return i + 1
    }

    /// Index offset from current index
    /// - Parameters:
    ///   - i: current index
    ///   - n: offset distance
    @inline(__always)
    public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
        return i + n
    }

    /// Form index after current index
    /// - Parameter i: current index
    @inline(__always)
    public func formIndex(after i: inout Index) {
        i += 1
    }

    /// Calculate distance from start to end indices
    /// - Parameters:
    ///   - start: start index
    ///   - end: end index
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> IndexDistance {
        return end - start
    }
}
