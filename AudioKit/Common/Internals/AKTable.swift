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
public struct AKTable {

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
        values = [Float]()
        let slope = Float(4.0) / Float(size)
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            if (i + phaseOffset) % size < size / 2 {
                values.append(slope * Float((i + phaseOffset) % size) - 1.0)
            } else {
                values.append(slope * Float((-i - phaseOffset) % size) + 3.0)
            }
        }
    }

    /// Instantiate the table as a square wave
    mutating func standardSquareWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            if (i + phaseOffset) % size < size / 2 {
                values.append(-1.0)
            } else {
                values.append(1.0)
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func standardSawtoothWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            values.append(-1.0 + 2.0 * Float((i + phaseOffset) % size) / Float(size))
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func standardReverseSawtoothWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0..<size {
            values.append(1.0 - 2.0 * Float((i + phaseOffset) % size) / Float(size))
        }
    }

    /// Instantiate the table as a sine wave
    mutating func standardSineWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            values.append(sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(size)))
        }
    }

    /// Instantiate the table as a triangle wave
    mutating func positiveTriangleWave() {
        values = [Float]()
        let slope = Float(2.0) / Float(size)
        for i in 0..<size {
            let phaseOffset = Int(phase * size)
            if (i + phaseOffset) % size < size / 2 {
                values.append(slope * Float((i + phaseOffset) % size))
            } else {
                values.append(slope * Float((-i - phaseOffset) % size) + 2.0)
            }
        }
    }

    /// Instantiate the table as a square wave
    mutating func positiveSquareWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            if (i + phaseOffset) % size < size / 2 {
                values.append(0.0)
            } else {
                values.append(1.0)
            }
        }
    }

    /// Instantiate the table as a sawtooth wave
    mutating func positiveSawtoothWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            values.append(Float((i + phaseOffset) % size) / Float(size))
        }
    }

    /// Instantiate the table as a reverse sawtooth wave
    mutating func positiveReverseSawtoothWave() {
        values = [Float]()
        let phaseOffset = Int(phase * size)
        for i in 0 ..< size {
            values.append(1.0 - Float((i + phaseOffset) % size) / Float(size))
        }
    }

    /// Instantiate the table as a sine wave
    mutating func positiveSineWave() {
        values = [Float]()
        let phaseOffset = Int(phase*size)
        for i in 0 ..< size {
            values.append(0.5 + 0.5 * sin(2 * 3.14159265 * Float(i + phaseOffset) / Float(size)))
        }
    }
}
