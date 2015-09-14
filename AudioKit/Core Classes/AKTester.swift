//
//  AKTester.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/13/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** A class to manage AudioKit Tests */
@objc class AKTester : NSObject {
    
    /** Internal reference to SoundPipe */
    var data: UnsafeMutablePointer<sp_data> = nil
    
    /** The collection of instruments */
    var instruments: [AKInstrument] = []
    
    /** Start up SoundPipe */
    override init() {
        super.init()
        sp_createn(&data, 2)
    }
    
    /** Release memory */
    func teardown() {
        sp_destroy(&data)
    }

    func run(duration: Float) {
        let samples = duration * 44100
        
        for operation in AKManager.sharedManager.instruments.first!.operations {
            operation.compute()
        }
    }
    
}
