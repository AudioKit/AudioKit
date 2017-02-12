//
//  AKVariSpeed.swift
//  AudioKit
//
//  Created by Eiríkur Orri Ólafsson, revision history on GitHub
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's VariSpeed Audio Unit
/// 
open class AKVariSpeed: AKNode, AKToggleable {

    fileprivate let variSpeedAU = AVAudioUnitVarispeed()

    /// Rate (rate) ranges form 0.25 to 4.0 (Default: 1.0)
    open var rate: Double = 1.0 {
        didSet {
            rate = (0.25...4).clamp(rate)
            variSpeedAU.rate = Float(rate)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return rate != 1.0
    }

    fileprivate var lastKnownRate: Double = 1.0

    /// Initialize the varispeed node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.25 to 4.0 (Default: 1.0)
    ///
    public init(_ input: AKNode, rate: Double = 1.0) {
        self.rate = rate
        lastKnownRate = rate

        super.init()
        self.avAudioNode = variSpeedAU
        AudioKit.engine.attach(self.avAudioNode)
        input.addConnectionPoint(self)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        rate = lastKnownRate
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        lastKnownRate = rate
        rate = 1.0
    }
}
