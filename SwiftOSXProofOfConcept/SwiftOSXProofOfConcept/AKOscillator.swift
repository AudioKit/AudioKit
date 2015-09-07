//
//  AKOscillator.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/7/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

import Foundation

@objc class AKOscillator : AKParameter {
    
    var osc = UnsafeMutablePointer<sp_osc>.alloc(1)
    
    var table = AKTable()
    private var phase: Float = 0
    
    var frequency: Float = 440 {
        didSet {
            osc.memory.freq = frequency
        }
    }
    
    override init() {
        super.init()
        create()
    }
    
    convenience init(
        frequency: AKParameter,
        amplitude: AKParameter,
        phase: Float)
    {
        self.init()
        frequency.bind(&osc.memory.freq)
        amplitude.bind(&osc.memory.amp)
        self.phase = phase
    }
    
    override func create() {
        sp_osc_create(&osc)
        sp_osc_init(AKManager.sharedManager.data, osc, table.ftbl, phase)
    }
    
    override func compute() -> Float {
        sp_osc_compute(AKManager.sharedManager.data, osc, nil, &value);
        pointer.memory = value
        return value
    }
override     
    func destroy() {
        sp_osc_destroy(&osc)
    }
    
    
}