//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A table of values accessible as a waveform or lookup mechanism */
class AKTable : AKParameter {
    
    /** Pointer to the SoundPipe table */
    var ftbl: UnsafeMutablePointer<sp_ftbl> = nil  //not just nil
    
    /** Initialize and set up the default table */
    override init() {
        super.init()
        setup()
    }
    
    /** Set up the table as the default sine wave */
     func setup() {
        sp_ftbl_create(AKManager.sharedManager.data, &ftbl, 4096)
        sp_gen_sine(AKManager.sharedManager.data, ftbl);
    }
    
    /** Release the table's memory */
    override func teardown() {
        sp_ftbl_destroy(&ftbl)
    }

}