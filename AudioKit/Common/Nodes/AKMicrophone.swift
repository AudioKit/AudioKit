//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Audio from the standard input */
public class AKMicrophone: AKNode {
    
    /** Initialize the microphone */
    public override init() {
        super.init()
        #if !os(tvOS)
        output = AKManager.sharedInstance.engine.inputNode
        #endif
    }
}
