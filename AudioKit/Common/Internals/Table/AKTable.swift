//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Supported default table types
@objc public enum AKTableType: Int, Codable {
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

    /// Zeros
    case zero
}

/// A table of values accessible as a waveform or lookup mechanism
public class AKTable: NSObject, MutableCollection, Codable {
    public typealias Index = Int
    public typealias IndexDistance = Int
    public typealias Element = Float
    public typealias SubSequence = ArraySlice<Element>

    // MARK: - Properties    /// Values stored in the table

    internal var content = [Element]()

    /// Phase of the table
    public var phase: Float {
        didSet {
            phase = (0...1).clamp(phase)
        }
    }

    public var startIndex: Index {
        return content.startIndex
    }

    public var endIndex: Index {
        return content.endIndex
    }

    public var count: IndexDistance {
        return content.count
    }

    public subscript(index: Index) -> Element {
        get {
            return content[index]
        }
        set {
            content[index] = newValue
        }
    }

    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            return content[bounds]
        }
        set {
            content[bounds] = newValue
        }
    }

    /// Type of table
    var type: AKTableType

    // MARK: - Initialization

    /// Initialize and set up the default table
    ///
    /// - Parameters:
    ///   - type: AKTableType of the new table
    ///   - phase: Phase offset
    ///   - count: Size of the table (multiple of 2)
    ///
    @objc public init(_ type: AKTableType = .sine,
                phase: Float = 0,
                count: IndexDistance = 4_096) {
        self.type = type
        self.phase = phase

        self.content = [Element](zeros: count)

        super.init()

        switch type {
        case .sine:
            self.standardSineWave()
        case .sawtooth:
            self.standardSawtoothWave()
        case .triangle:
            self.standardTriangleWave()
        case .reverseSawtooth:
            self.standardReverseSawtoothWave()
        case .square:
            self.standardSquareWave()
        case .positiveSine:
            self.positiveSineWave()
        case .positiveSawtooth:
            self.positiveSawtoothWave()
        case .positiveTriangle:
            self.positiveTriangleWave()
        case .positiveReverseSawtooth:
            self.positiveReverseSawtoothWave()
        case .positiveSquare:
            self.positiveSquareWave()
        case .zero:
            self.zero()
        }
    }

    /// Create table from audio file
    @objc public convenience init(file: AKAudioFile) {
        let size = Int(file.samplesCount)
        self.init(count: size)

        if let data = file.floatChannelData?[0] {
            for i in 0 ..< size {
                self[i] = data[i]
            }
        }
    }

    /// Offset of the phase
    public var phaseOffset: Int {
        @inline(__always)
        get {
            return Int(phase * count)
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
            content[i] = Float(sin(2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
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
            content[i] = Float(0.5 + 0.5 * sin(2 * 3.141_592_65 * Float(i + phaseOffset) / Float(count)))
        }
    }

    /// Instantiate the table with zero values
    func zero() {
        for i in indices {
            content[i] = 0
        }
    }
}

extension AKTable: RandomAccessCollection {
    public typealias Indices = Array<Element>.Indices

    @inline(__always)
    public func index(before i: Index) -> Index {
        return i - 1
    }

    @inline(__always)
    public func index(after i: Index) -> Index {
        return i + 1
    }

    @inline(__always)
    public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
        return i + n
    }

    @inline(__always)
    public func formIndex(after i: inout Index) {
        i += 1
    }

    @inline(__always)
    public func distance(from start: Index, to end: Index) -> IndexDistance {
        return end - start
    }
}
