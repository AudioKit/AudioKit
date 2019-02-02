//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// AudioKit version of Apple's Mixer Node. Mixes a varaiadic list of AKNodes.
open class AKMixer: AKNode, AKToggleable, AKInput {
    /// The internal mixer node
    fileprivate var mixerAU = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU.outputVolume = Float(volume)
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the mixer is serving any output or if it is stopped.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    @objc public override init() {
        super.init(avAudioNode: mixerAU, attach: true)
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of AKNodes
    ///
    //swiftlint:disable force_unwrapping
    public convenience init(_ inputs: AKNode?...) {
        self.init(inputs.compactMap { $0 })
    }
    //swiftlint:enable force_unwrapping

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: An array of AKNodes
    ///
    @objc public convenience init(_ inputs: [AKNode]) {
        self.init()
        for input in inputs {
            input.connect(to: self)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    /// Detach
    @objc open override func detach() {
      super.detach()
    }

    /// Connnect another input after initialization // Deprecated
    ///
    /// - parameter input: AKNode to connect
    /// - parameter bus: what channel of the mixer to connect on.
    /// If you use this it is up to your application to keep track of what inputs are in use to make sure you
    /// don't overwrite an existing channel with an active node that is active.

    //swiftlint:disable line_length
    @available(*, deprecated, message: "use connect(to:AKNode) or connect(to:AKNode, bus:Int) from the upstream node instead")
    open func connect(_ input: AKNode?, bus: Int? = nil) {
        input?.connect(to: self, bus: bus ?? nextInput.bus)
    }
    //swiftlint:enable line_length

    // It is not possible to use @objc on AKOutput extension, so [connectWithInput:bus:]
    /// Connect for Objectivec access, with bus definition
    @objc open func connect(input: AKNode?, bus: Int) {
      input?.connect(to: self, bus: bus)
    }

    // It is not possible to use @objc on AKOutput extension, so [connectWithInput:]
    /// Connect for Objectivec access
    @objc open func connect(input: AKNode?) {
      input?.connect(to: self, bus: nextInput.bus)
    }

}
