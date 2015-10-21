//
//  AKOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Parent class for all AudioKit operations */
public class AKOperation {
    
    /** Output of the operation */
    public var output: AVAudioNode?
    
    /** Required initialization method */
    init() {
        // Override in subclass
    }
}