//
//  AKOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/7/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A simple oscillator */
@objc class AKOscillator : AKParameter {
    
    var osc = UnsafeMutablePointer<sp_osc>.alloc(1)
    
    var table = AKTable()
    private var phase: Float = 0
    
    var frequency: AKParameter = akp(440) {
        didSet {
            frequency.bind(&osc.memory.freq)
        }
    }
    
    var amplitude: AKParameter = akp(1) {
        didSet {
            amplitude.bind(&osc.memory.amp)
        }
    }
    
    /** Instantiates the oscillator with default values */
    override init() {
        super.init()
        setup()
    }
    
     init(phase iphs: Float) {
        super.init()
        setup(phase: iphs)
    }
    
    /** Instantiates the oscillator with all values
    
    :param: frequency In cycles per second, or Hz. [Default Value: 440]
    :param: amplitude Signal strength. [Default Value: 0.5]
    :param: phase Oscillator phase [Default Value: 0]
    */
    convenience init(
        frequency freq: AKParameter,
        amplitude amp:  AKParameter,
        phase iphs: Float)
    {
        self.init(phase: iphs)
        
        frequency = freq
        amplitude = amp
        
        frequency.bind(&osc.memory.freq)
        amplitude.bind(&osc.memory.amp)
    }
    
    /** Internal set up function */
    internal func setup(phase: Float = 0) {
        sp_osc_create(&osc)
        sp_osc_init(AKManager.sharedManager.data, osc, table.ftbl, phase)
    }
    
    /** Computation of the next value */
    override func compute() -> Float {
        sp_osc_compute(AKManager.sharedManager.data, osc, nil, &value);
        pointer.memory = value
        return value
    }
    
    /** Release of memory */
    override func teardown() {
        sp_osc_destroy(&osc)
    }
    
    
}