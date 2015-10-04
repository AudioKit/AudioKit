//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A table of values accessible as a waveform or lookup mechanism */
@objc class AKTable : NSObject {
    
    // MARK: - Properties
    
    /** Pointer to the SoundPipe table */
    var ftbl: UnsafeMutablePointer<sp_ftbl> = UnsafeMutablePointer.alloc(1)

    /** Size of the table */
    private var size: Int
    
    // MARK: - Initialization
    
    /** Initialize and set up the default table */
    init(size tableSize: Int = 4096) {
        size = tableSize
        super.init()
        setup()
    }
    
    // MARK: - Initializers with Generators
    
    /** Instantiate the table as a triangle wave
    - parameter size: Size of the table (multiple of 2)
    */
    class func standardTriangleWave(size tableSize: Int = 4096) -> AKTable {
        let triangle = AKTable(size: tableSize)
        let slope = Float(4.0) / Float(triangle.size)
        for i in 0..<triangle.size {
            if i < triangle.size / 2 {
                triangle.ftbl.memory.tbl[i] = slope * Float(i) - 1.0
            } else {
                triangle.ftbl.memory.tbl[i] = slope * Float(-i) + 3.0
            }
        }
        return triangle
    }

    /** Instantiate the table as a square wave
    - parameter size: Size of the table (multiple of 2)
    */
    class func standardSquareWave(size tableSize: Int = 4096) -> AKTable {
        let square = AKTable(size: tableSize)
        for i in 0..<square.size {
            if i < square.size / 2 {
                square.ftbl.memory.tbl[i] = -1.0
            } else {
                square.ftbl.memory.tbl[i] = 1.0
            }
        }
        return square
    }
    
    /** Instantiate the table as a sawtooth wave
    - parameter size: Size of the table (multiple of 2)
    */
    class func standardSawtoothWave(size tableSize: Int = 4096) -> AKTable {
        let sawtooth = AKTable(size: tableSize)
        for i in 0..<sawtooth.size {
            sawtooth.ftbl.memory.tbl[i] = -1.0 + 2.0*Float(i)/Float(sawtooth.size)
        }
        return sawtooth
    }

    /** Instantiate the table as a reverse sawtooth wave
    - parameter size: Size of the table (multiple of 2)
    */
    class func standardReverseSawtoothWave(size tableSize: Int = 4096) -> AKTable {
        let sawtooth = AKTable(size: tableSize)
        for i in 0..<sawtooth.size {
            sawtooth.ftbl.memory.tbl[i] = 1.0 - 2.0*Float(i)/Float(sawtooth.size)
        }
        return sawtooth
    }

    /** Instantiate the table as a sine wave
    - parameter size: Size of the table (multiple of 2)
    */
    class func standardSineWave(size tableSize: Int = 4096) -> AKTable {
        let sine = AKTable(size: tableSize)
        sp_gen_sine(AKManager.sharedManager.data, sine.ftbl);
        return sine
    }
    
    // MARK: - Internal
    
    /** Bind the memory of the SoundPipe value to this parameter */
    func bind(binding:UnsafeMutablePointer<sp_ftbl>)
    {
        ftbl = binding
    }
    
    /** Set up the Soundpipe variable */
    func setup() {
        sp_ftbl_create(AKManager.sharedManager.data, &ftbl, size)
    }
    
    /** Release the table's memory */
    func teardown() {
        sp_ftbl_destroy(&ftbl)
    }

}