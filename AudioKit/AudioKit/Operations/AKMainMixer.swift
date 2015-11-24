//
//  AKMainMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Basic mixer */
public class AKMainMixer: AKOperation {
    
    /** Initialize the mixer */
    public override init() {
        super.init()
        output = AKManager.sharedInstance.engine.mainMixerNode
    }
    
    public func connect(input: AKOperation) {
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
}
