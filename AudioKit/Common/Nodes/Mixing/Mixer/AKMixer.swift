//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's Mixer Node. Mixes a varaiadic list of AKNodes.
open class AKMixer: AKNode, AKToggleable {
    fileprivate let mixerAU = AVAudioMixerNode()

    /// Output Volume (Default 1)
    open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU.outputVolume = Float(volume)
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the mixer is serving any output or if it is stopped.
    open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    ///
    /// - parameter inputs: A varaiadic list of AKNodes
    ///
    public override init() {
        super.init()
        self.avAudioNode = mixerAU
        AudioKit.engine.attach(self.avAudioNode)
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A varaiadic list of AKNodes
    ///
    public init(_ inputs: AKNode?...) {
        super.init()
        self.avAudioNode = mixerAU
        AudioKit.engine.attach(self.avAudioNode)
        for input in inputs {
            connect(input)
        }
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of AKNodes
    ///
    public init(_ inputs: [AKNode]) {
        super.init()
        self.avAudioNode = mixerAU
        AudioKit.engine.attach(self.avAudioNode)
        for input in inputs {
            connect(input)
        }
    }

    /// Connnect another input after initialization
    ///
    /// - parameter input: AKNode to connect
    ///
    open func connect(_ input: AKNode?) {
        var wasRunning = false
        if AudioKit.engine.isRunning {
            wasRunning = true
            AudioKit.stop()
        }
        if let existingInput = input {
            existingInput.connectionPoints.append(AVAudioConnectionPoint(node: mixerAU, bus: mixerAU.numberOfInputs))
            AudioKit.engine.connect(existingInput.avAudioNode,
                                    to: existingInput.connectionPoints,
                                    fromBus: 0,
                                    format: AudioKit.format)
        }
        if wasRunning {
            AudioKit.start()
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }
}
