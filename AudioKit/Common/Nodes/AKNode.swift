//
//  AKNode.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Parent class for all AudioKit Nodes */
public class AKNodes {
    
    /** Output of the node */
    public var output: AVAudioNode?
    
    /** Required initialization method */
    init() {
        // Override in subclass
    }
}
