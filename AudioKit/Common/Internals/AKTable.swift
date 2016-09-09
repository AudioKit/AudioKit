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
    case Sine

    /// Standard triangle waveform
    case Triangle

    /// Standard square waveform
    case Square

    /// Standard sawtooth waveform
    case Sawtooth

    /// Reversed sawtooth waveform
    case ReverseSawtooth

    /// Sine wave from 0-1
    case PositiveSine

    /// Triangle waveform from 0-1
    case PositiveTriangle

    /// Square waveform from 0-1
    case PositiveSquare

    /// Sawtooth waveform from 0-1
    case PositiveSawtooth

    /// Reversed sawtooth waveform from 0-1
    case PositiveReverseSawtooth


}

/// A table of values accessible as a waveform or lookup mechanism
public struct AKTable: Collection {

    // MARK: - Properties

    /// Values stored in the table
    public var values = [Float]()

    /// Number of values stored in the table
    var phase: Double {
        didSet {
            if phase > 1.0 {
                phase = 1.0
            } else if phase < 0.0 {
                phase = 0.0
            }
        }
    }
    
    /// Number of values stored in the table
    var size = 4096

    public var startIndex: Int {
        return values.startIndex
    }

    public var endIndex: Int {
        return values.endIndex
    }

    public subscript(index: Int) -> Float {
        return values[index]
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
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
    public init(_ type: AKTableType = .Sine,
                  phase: Double = 0,
                  size: Int = 4096) {
        self.type = type
        self.phase = phase
        self.size = size
        
        self.values = [Float](zeroes: size)
        
        switch type {
        case .Sine:
            self.standardSineWave()
        case .Sawtooth:
            self.standardSawtoothWave()
        case .Triangle:
            self.standardTriangleWave()
        case .ReverseSawtooth:
            self.standardReverseSawtoothWave()
        case .Square:
            self.standardSquareWave()
        case .PositiveSine:
            self.positiveSineWave()
        case .PositiveSawtooth:
            self.positiveSawtoothWave()
        case .PositiveTriangle:
            self.positiveTriangleWave()
        case .PositiveReverseSawtooth:
            self.positiveReverseSawtoothWave()
        case .PositiveSquare:
            self.positiveSquareWave()
        }
    }

    /// Instantiate the table as a triangle wave
    mutating func standardTriangleWave() {
        let slope = Float(4.0) / Float(count)
        let phaseOffset = Int(phase * count)
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                values[i] = slope * Float((i + phaseOffset) % count) - 1.0
            } else {
                values[i] = slope * Float((-i - phaseOffset) % count) + 3.0
            }
        }
    }

    /// Instantiate the table as a square wave
    mutating func standardSquareWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                values[i] = -1.0
            } else {
                values[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func standardSawtoothWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = -1.0 + 2.0 * Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func standardReverseSawtoothWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = 1.0 - 2.0 * Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a sine wave
    mutating func standardSineWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(count))
        }
    }

    /// Instantiate the table as a triangle wave
    mutating func positiveTriangleWave() {
        let slope = Float(2.0) / Float(count)
        for i in indices {
            let phaseOffset = Int(phase * count)
            if (i + phaseOffset) % count < count / 2 {
                values[i] = slope * Float((i + phaseOffset) % count)
            } else {
                values[i] = slope * Float((-i - phaseOffset) % count) + 2.0
            }
        }
    }

    /// Instantiate the table as a square wave
    mutating func positiveSquareWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            if (i + phaseOffset) % count < count / 2 {
                values[i] = 0.0
            } else {
                values[i] = 1.0
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func positiveSawtoothWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func positiveReverseSawtoothWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = 1.0 - Float((i + phaseOffset) % count) / Float(count)
        }
    }

    /// Instantiate the table as a sine wave
    mutating func positiveSineWave() {
        let phaseOffset = Int(phase * count)
        for i in indices {
            values[i] = 0.5 + 0.5 * sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(count))
        }
    }
}
