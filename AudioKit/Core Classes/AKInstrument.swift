//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** A parent class to all instruments */
@objc class AKInstrument : NSObject {
    
    /** All operations which need to be computed for this instrument */
    var operations: [AKParameter] = []
    
    /** Initialize and append to the list of instruments */
    init() {
        AKManager.sharedManager.instruments.append(self)
    }
}