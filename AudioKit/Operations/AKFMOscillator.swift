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

    var baseFrequency: AKParameter = akp(440) {
        didSet {
            baseFrequency.bind(&fosc.memory.freq)
        }
    }
    
    var carrierMultiplier: AKParameter = akp(1) {
        didSet {
            carrierMultiplier.bind(&fosc.memory.car)
        }
    }
    
    var modulatingMultiplier: AKParameter = akp(1) {
        didSet {
            modulatingMultiplier.bind(&fosc.memory.mod)
        }
    }
    
    var modulationIndex: AKParameter = akp(1) {
        didSet {
            modulationIndex.bind(&fosc.memory.indx)
        }
    }
    
    var amplitude: AKParameter = akp(0.5) {
        didSet {
            amplitude.bind(&fosc.memory.amp)
        }
    }
    
    /** Instantiates the fm oscillator with default values */
    override init() {
        super.init()
        setup()
        bindAll()
    }
    
    /** Instantiates the fm oscillator with all values
    
    :param: baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
    :param: carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
    :param: modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
    :param: modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
    :param: amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
    */
    convenience init(
        baseFrequency        freq: AKParameter,
        carrierMultiplier    car:  AKParameter,
        modulatingMultiplier mod:  AKParameter,
        modulationIndex      indx: AKParameter,
        amplitude            amp:  AKParameter)
    {
        self.init()
        
        baseFrequency        = freq
        carrierMultiplier    = car
        modulatingMultiplier = mod
        modulationIndex      = indx
        amplitude            = amp

        bindAll()
    }
    
    /** Bind every property to the internal oscillator */
    internal func bindAll() {
        baseFrequency       .bind(&fosc.memory.freq)
        carrierMultiplier   .bind(&fosc.memory.car)
        modulatingMultiplier.bind(&fosc.memory.mod)
        modulationIndex     .bind(&fosc.memory.indx)
        amplitude           .bind(&fosc.memory.amp)
    }
    
    /** Internal set up function */
    internal func setup() {
        sp_fosc_create(&fosc)
        sp_fosc_init(AKManager.sharedManager.data, fosc, table.ftbl)
    }
    
    /** Computation of the next value */
    override func compute() -> Float {
        sp_fosc_compute(AKManager.sharedManager.data, fosc, nil, &value);
        pointer.memory = value
        return value
    }
    
    /** Release of memory */
    override func teardown() {
        sp_fosc_destroy(&fosc)
    }
    
    
}