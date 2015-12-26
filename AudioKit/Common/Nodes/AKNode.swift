//
//  AKNode.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Protocol for all AudioKit Nodes
public protocol AKNode {
    
    /// Output of the node 
    var avAudioNode: AVAudioNode { get set }
}