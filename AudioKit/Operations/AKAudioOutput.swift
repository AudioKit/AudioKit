//
//  AKAudioOutput.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/10/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Output audio to the speakers */
@objc class AKAudioOutput : AKParameter {
    
    private var input = AKParameter()

    init(input sourceInput: AKParameter) {
        super.init()
        input = sourceInput
    }
    
    override func compute() {
        sp_out(AKManager.sharedManager.data, 0, input.leftOutput)
        sp_out(AKManager.sharedManager.data, 1, input.rightOutput)
    }
    
}
