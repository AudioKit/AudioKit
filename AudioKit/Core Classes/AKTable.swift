//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A table of values accessible as a waveform or lookup mechanism */
@objc class AKTable : AKParameter {
    
    /** Pointer to the SoundPipe table */
    var ftbl: UnsafeMutablePointer<sp_ftbl> = nil  //not just nil
    var table: UnsafeMutablePointer<Float> = nil
    private var size: Int
    
    /** Initialize and set up the default table */
    init(size tableSize: Int = 4096) {
        size = tableSize
        super.init()
        setup()
        standardSineWave()
    }
    
    func standardTriangleWave() {
        let slope = Float(4.0) / Float(size)
        for i in 0..<size {
            if i < size / 2 {
                ftbl.memory.tbl[i] = slope * Float(i) - 1.0
            } else {
                ftbl.memory.tbl[i] = slope * Float(-i) + 3.0
            }
        }
    }
    
    func standardSquareWave() {
        for i in 0..<size {
            if i < size / 2 {
                ftbl.memory.tbl[i] = -1.0
            } else {
                ftbl.memory.tbl[i] = 1.0
            }            
        }
    }
    
    func standardSineWave() {
        sp_gen_sine(AKManager.sharedManager.data, ftbl);
    }
    
    func setup() {
        sp_ftbl_create(AKManager.sharedManager.data, &ftbl, size)
    }
    
    /** Release the table's memory */
    override func teardown() {
        sp_ftbl_destroy(&ftbl)
    }

}