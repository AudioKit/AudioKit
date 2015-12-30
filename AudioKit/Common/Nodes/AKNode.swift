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
    var connectionPoints: [AVAudioConnectionPoint] { get set }
}

public extension AKNode {
    public mutating func addConnectionPoint(node: AKNode) {
        connectionPoints.append(AVAudioConnectionPoint(node: node.avAudioNode, bus: 0))
        AKManager.sharedInstance.engine.connect(avAudioNode,
            toConnectionPoints: connectionPoints,
            fromBus: 0,
            format: AKManager.format)
    }
}
