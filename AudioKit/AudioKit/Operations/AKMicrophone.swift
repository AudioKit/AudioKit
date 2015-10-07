//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

public class AKMicrophone: AKOperation {
    public override init() {
        super.init()
        output = AKManager.sharedManager.engine.inputNode
    }
    
}