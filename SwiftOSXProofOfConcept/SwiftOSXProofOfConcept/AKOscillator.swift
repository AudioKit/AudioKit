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
    
    /** Instantiates the oscillator with default values */
    override init() {
        super.init()
        create()
    }
    
    /** Instantiates the oscillator with all values
    
    :param: frequency In cycles per second, or Hz. [Default Value: 440]
    :param: amplitude Signal strength. [Default Value: 0.5]
    :param: phase Oscillator phase [Default Value: 0]
    */
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
    /** Internal set up function */
        sp_osc_create(&osc)
        sp_osc_init(AKManager.sharedManager.data, osc, table.ftbl, phase)
    }
    
    /** Computation of the next value */
    override func compute() -> Float {
        sp_osc_compute(AKManager.sharedManager.data, osc, nil, &value);
        pointer.memory = value
        return value
    }
override     
    func destroy() {
    /** Release of memory */
        sp_osc_destroy(&osc)
    }
    
    
}