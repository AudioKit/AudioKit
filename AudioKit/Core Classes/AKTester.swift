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
    var test: UnsafeMutablePointer<sp_test> = nil
    
    /** The collection of instruments */
    var instruments: [AKInstrument] = []
    
    var instrument = DemoInstrument()
    
    /** Start up SoundPipe */
    override init() {
        super.init()
        sp_test_create(&test, 10*44100)
    }
    
    /** Release memory */
    func teardown() {
        sp_test_destroy(&test)
    }

    func run(duration: Float) {
        let samples = 10 * 44100
        
        let md5 = "e9f8984c6dcc8281c9adede9fdf5ab4b"
        let md52 = (md5 as NSString).UTF8String
        
        for _ in 0..<samples {
            for operation in AKManager.sharedManager.instruments.first!.operations {
                operation.compute()
            }
            sp_test_add_sample(test, AKManager.sharedManager.data.memory.out[0])
        }

        
        if sp_test_compare(test, md52) == SP_OK {
            print("it matches!")
        } else {
            let goodmd5 = String(CString: test.memory.md5, encoding: NSUTF8StringEncoding)
            
            print("sorry the rendered hash was \(goodmd5) and you had \(md5)")
        }
    }
    
}
