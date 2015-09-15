//
//  AKAudioOutput.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/10/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Output audio to the speakers */
@objc class AKAudioOutput : AKParameter {
    
    private var input = AKParameter()

    /** Create an instance of an audio output
    - parameter input: The audio signal
    */
    init(input sourceInput: AKParameter) {
        super.init()
        input = sourceInput
        dependencies = [input]
    }
    
    /** Place the audio signal in the output chain
    */
    override func compute() {
        sp_out(AKManager.sharedManager.data, 0, input.leftOutput)
        sp_out(AKManager.sharedManager.data, 1, input.rightOutput)
    }
    
}
