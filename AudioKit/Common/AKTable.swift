//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

public enum AKTableType: String {
    case Sine, Triangle, Square, Sawtooth, ReverseSawtooth
}

/** A table of values accessible as a waveform or lookup mechanism */
public struct AKTable {
    
    // MARK: - Properties
    
    public var values = [Float]()
    var size = 4096
    var type: AKTableType
    
    // MARK: - Initializers with Generators
    /** Initialize and set up the default table 
    - parameter size: Size of the table (multiple of 2)
    */
    public init(_ tableType: AKTableType = .Sine, size tableSize: Int = 4096) {
        type = tableType
        size = tableSize
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
        }
    }
    
    /** Instantiate the table as a triangle wave */
    mutating func standardTriangleWave() {
        values = [Float]()
        let slope = Float(4.0) / Float(size)
        for i in 0..<size {
            if i < size / 2 {
                values.append(slope * Float(i) - 1.0)
            } else {
                values.append(slope * Float(-i) + 3.0)
            }
        }
    }

    /** Instantiate the table as a square wave */
    mutating func standardSquareWave() {
        values = [Float]()
        for i in 0..<size {
            if i < size / 2 {
                values.append(-1.0)
            } else {
                values.append(1.0)
            }
        }
    }
    
    /** Instantiate the table as a sawtooth wave */
    mutating func standardSawtoothWave() {
        values = [Float]()
        for i in 0..<size {
            values.append(-1.0 + 2.0*Float(i)/Float(size))
        }
    }

    /** Instantiate the table as a reverse sawtooth wave */
    mutating func standardReverseSawtoothWave() {
        values = [Float]()
        for i in 0..<size {
            values.append(1.0 - 2.0*Float(i)/Float(size))
        }
    }

    /** Instantiate the table as a sine wave */
    mutating func standardSineWave() {
        values = [Float]()
        for i in 0..<size {
            values.append(sin(2 * 3.14159265 * Float(i)/Float(size)))
        }
    }
}