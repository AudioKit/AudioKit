//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A table of values accessible as a waveform or lookup mechanism */
public class AKTable {
    
    // MARK: - Properties
    
    public var values = [Float]()
    public var size = 4096
    
    // MARK: - Initializers with Generators
    /** Initialize and set up the default table */
    public init(size tableSize: Int = 4096) {
        size = tableSize
    }
    
    /** Instantiate the table as a triangle wave
    - parameter size: Size of the table (multiple of 2)
    */
    public class func standardTriangleWave(size tableSize: Int = 4096) -> AKTable {
        let triangle = AKTable(size: tableSize)
        let slope = Float(4.0) / Float(triangle.size)
        for i in 0..<triangle.size {
            if i < triangle.size / 2 {
                triangle.values.append(slope * Float(i) - 1.0)
            } else {
                triangle.values.append(slope * Float(-i) + 3.0)
            }
        }
        return triangle
    }

    /** Instantiate the table as a square wave
    - parameter size: Size of the table (multiple of 2)
    */
    public class func standardSquareWave(size tableSize: Int = 4096) -> AKTable {
        let square = AKTable(size: tableSize)
        for i in 0..<square.size {
            if i < square.size / 2 {
                square.values.append(-1.0)
            } else {
                square.values.append(1.0)
            }
        }
        return square
    }
    
    /** Instantiate the table as a sawtooth wave
    - parameter size: Size of the table (multiple of 2)
    */
    public class func standardSawtoothWave(size tableSize: Int = 4096) -> AKTable {
        let sawtooth = AKTable(size: tableSize)
        for i in 0..<sawtooth.size {
            sawtooth.values.append(-1.0 + 2.0*Float(i)/Float(sawtooth.size))
        }
        return sawtooth
    }

    /** Instantiate the table as a reverse sawtooth wave
    - parameter size: Size of the table (multiple of 2)
    */
    public class func standardReverseSawtoothWave(size tableSize: Int = 4096) -> AKTable {
        let sawtooth = AKTable(size: tableSize)
        for i in 0..<sawtooth.size {
            sawtooth.values.append(1.0 - 2.0*Float(i)/Float(sawtooth.size))
        }
        return sawtooth
    }

    /** Instantiate the table as a sine wave
    - parameter size: Size of the table (multiple of 2)
    */
    public class func standardSineWave(size tableSize: Int = 4096) -> AKTable {
        let sine = AKTable(size: tableSize)
        for i in 0..<sine.size {
            sine.values.append(sin(2 * 3.14159265 * Float(i)/Float(sine.size)))
        }
        return sine
    }


}