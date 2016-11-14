//
//  AKDCBlock.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1]) 
/// Based on work by Perry Cook.
///
/// - parameter input: Input node to process
///
open class AKDCBlock: AKNode, AKToggleable, AKComponent {
    static let ComponentDescription = AudioComponentDescription(effect: "dcbk")

    // MARK: - Properties

    internal var internalAU: AKDCBlockAudioUnit?
    internal var token: AUParameterObserverToken?



    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    ///
    public init( _ input: AKNode) {
        _Self.register()

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKDCBlockAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
