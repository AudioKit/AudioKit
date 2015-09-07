//
//  AKTable.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class AKTable : AKParameter {
    var ftbl: UnsafeMutablePointer<sp_ftbl> = nil  //not just nil
    
    override init() {
        super.init()
        create()
    }
    
    func create() {
        sp_ftbl_create(AKManager.sharedManager.data, &ftbl, 4096)
        sp_gen_sine(AKManager.sharedManager.data, ftbl);
    }
    
    func destroy() {
        sp_ftbl_destroy(&ftbl)
    }

}