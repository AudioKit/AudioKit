//
//  AKChowningReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is was built using the JC reverb implentation found in FAUST. According
/// to the source code, the specifications for this implementation were found on
/// an old SAIL DART backup tape.
/// This class is derived from the CLM JCRev function, which is based on the use
/// of networks of simple allpass and comb delay filters.  This class implements
/// three series allpass units, followed by four parallel comb filters, and two
/// decorrelation delay lines in parallel at the output.
///
open class AKChowningReverb: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKChowningReverbAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "jcrv")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - parameter input: Input node to process
    ///
    public init(_ input: AKNode) {
        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
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
