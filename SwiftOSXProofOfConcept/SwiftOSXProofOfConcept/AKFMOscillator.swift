//
//  AKFMOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** Frequency Modulating Oscillator */
@objc class AKFMOscillator : AKParameter {
    
    var fosc = UnsafeMutablePointer<sp_fosc>.alloc(1) // allocate 1
    
    var table = AKTable()

    var frequency: Float = 440 {
        didSet {
            fosc.memory.freq = frequency
        }
    }
    
    var index: Float = 1 {
        didSet {
            fosc.memory.indx = index
        }
    }
    
    /** Instantiates the fm oscillator with default values */
    override init() {
        super.init()
        create()
    }
    
    /** Instantiates the fm oscillator with all values
    
    :param: baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
    :param: carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
    :param: modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
    :param: modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
    :param: amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
    */
    convenience init(
        baseFrequency: AKParameter,
        carrierMultiplier: AKParameter,
        modulatingMultiplier: AKParameter,
        modulationIndex: AKParameter,
        amplitude: AKParameter)
    {
        self.init()
        baseFrequency.bind(&fosc.memory.freq)
        carrierMultiplier.bind(&fosc.memory.car)
        modulatingMultiplier.bind(&fosc.memory.mod)
        modulationIndex.bind(&fosc.memory.indx)
        amplitude.bind(&fosc.memory.amp)
    }
    
    override func create() {
    /** Internal set up function */
        sp_fosc_create(&fosc)
        sp_fosc_init(AKManager.sharedManager.data, fosc, table.ftbl)
    }
    
    /** Computation of the next value */
    override func compute() -> Float {
        sp_fosc_compute(AKManager.sharedManager.data, fosc, nil, &value);
        pointer.memory = value
        return value
    }
    
    override func destroy() {
    /** Release of memory */
        sp_fosc_destroy(&fosc)
    }
    
    
}