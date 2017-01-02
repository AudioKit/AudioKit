//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 Aurelius Prochazka. All rights reserved.
//

import Foundation

/// Supported default table types
public enum AKTableType: String {
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

}

/// A table of values accessible as a waveform or lookup mechanism
public struct AKTable: MutableCollection {
    public typealias Index = Int
    public typealias IndexDistance = Int
    public typealias Element = Float
    public typealias SubSequence = ArraySlice<Element>

    // MARK: - Properties    /// Values stored in the table

    private var content = [Element]()

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
    ///   - tableType: AKTableType of teh new table
    ///   - size: Size of the table (multiple of 2)
    ///
    public init(_ type: AKTableType = .sine,
                phase: Float = 0,
                count: IndexDistance = 4096) {
        self.type = type
        self.phase = phase

        self.content = [Element](zeros: count)

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
        }
    }

    public var phaseOffset: Int {
        return Int(phase * count)
    }

    /// Instantiate the table as a triangle wave
    mutating func standardTriangleWave() {
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
    mutating func standardSquareWave() {
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = -1.0
            } else {
                content[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func standardSawtoothWave() {
        for i in indices {
            content[i] = Float(-1.0 + 2.0 * Float((i + phaseOffset) % count) / Float(count))
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func standardReverseSawtoothWave() {
        for i in indices {
            content[i] = Float(1.0 - 2.0 * Float((i + phaseOffset) % count) / Float(count))
        }
    }

    /// Instantiate the table as a sine wave
    mutating func standardSineWave() {
        for i in indices {
            content[i] = Float(sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(count)))
        }
    }

    /// Instantiate the table as a triangle wave
    mutating func positiveTriangleWave() {
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
    mutating func positiveSquareWave() {
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                content[i] = 0.0
            } else {
                content[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func positiveSawtoothWave() {
        for i in indices {
            content[i] = Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func positiveReverseSawtoothWave() {
        for i in indices {
            content[i] = Float(1.0) - Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a sine wave
    mutating func positiveSineWave() {
        for i in indices {
            content[i] = Float(0.5 + 0.5 * sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(count)))
        }
    }
}

extension AKTable: RandomAccessCollection  {
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
