//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

@objc class AKInstrument {
    var operations: [AKParameter] = []
    
    init() {
        AKManager.sharedManager.instruments.append(self)
    }

}