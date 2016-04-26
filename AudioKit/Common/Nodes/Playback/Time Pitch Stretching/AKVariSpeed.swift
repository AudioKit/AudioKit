//
//  AKVariSpeed.swift
//  AudioKit
//
//  Created by Eiríkur Orri Ólafsson, revision history on GitHub
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's VariSpeed Audio Unit
///
/// - parameter input: Input node to process
/// - parameter rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
///
public class AKVariSpeed: AKNode, AKToggleable {
    
    private let variSpeedAU = AVAudioUnitVarispeed()
    
    /// Rate (rate) ranges form 0.25 to 4.0 (Default: 1.0)
    public var rate : Double = 1.0 {
        didSet {
            if rate < 0.25 {
                rate = 0.25
            }
            if rate > 4.0 {
                rate = 4.0
            }
            variSpeedAU.rate = Float(rate)
        }
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return rate != 1.0
    }
    
    private var lastKnownRate: Double = 1.0
    
    /// Initialize the varispeed node
    ///
    /// - parameter input: Input node to process
    /// - parameter rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
    ///
    public init(_ input: AKNode, rate: Double = 1.0) {
        self.rate = rate
        lastKnownRate = rate
        
        super.init()
        self.avAudioNode = variSpeedAU
        AudioKit.engine.attachNode(self.avAudioNode)
        input.addConnectionPoint(self)
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        rate = lastKnownRate
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        lastKnownRate = rate
        rate = 1.0
    }
}
