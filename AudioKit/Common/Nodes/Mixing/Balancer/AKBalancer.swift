//
//  AKBalancer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This node outputs a version of the audio source, amplitude-modified so
/// that its rms power is equal to that of the comparator audio source. Thus a
/// signal that has suffered loss of power (eg., in passing through a filter
/// bank) can be restored by matching it with, for instance, its own source. It
/// should be noted that this modifies amplitude only; output signal is not
/// altered in any other respect.
///
/// - Parameters:
///   - input: Input node to process
///   - comparator: Audio to match power with
///
open class AKBalancer: AKNode, AKToggleable, AKComponent {
    static let ComponentDescription = AudioComponentDescription(mixer: "blnc")

    // MARK: - Properties
    
    internal var internalAU: AKBalancerAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this balance node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - comparator: Audio to match power with
    ///
    public init( _ input: AKNode, comparator: AKNode) {
        _Self.register()
        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKBalancerAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)

            comparator.connectionPoints.append(AVAudioConnectionPoint(node: self.avAudioNode, bus: 1))
            AudioKit.engine.connect(comparator.avAudioNode, to: comparator.connectionPoints, fromBus: 0, format: nil)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
