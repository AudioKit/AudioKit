//
//  AKAUDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKAUDelay: AKOperation {
    
    public init(_ input: AKOperation) {
        super.init()
        output = AVAudioUnitDelay()
        AKManager.sharedManager.engine.attachNode(output!)
        AKManager.sharedManager.engine.connect(input.output!, to: output!, format: nil)
    }
    
}