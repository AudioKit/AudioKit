//
//  AKBalancer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// This node outputs a version of the audio source, amplitude-modified so
/// that its rms power is equal to that of the comparator audio source. Thus a
/// signal that has suffered loss of power (eg., in passing through a filter
/// bank) can be restored by matching it with, for instance, its own source. It
/// should be noted that this modifies amplitude only; output signal is not
/// altered in any other respect.
///
open class AKBalancer: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBalancerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(mixer: "blnc")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this balance node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - comparator: Audio to match power with
    ///
    public init( _ input: AKNode?, comparator: AKNode) {
        _Self.register()
        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)

            comparator.connectionPoints.append(AVAudioConnectionPoint(node: self!.avAudioNode, bus: 1))
            AudioKit.engine.connect(comparator.avAudioNode, to: comparator.connectionPoints, fromBus: 0, format: nil)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
