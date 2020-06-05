// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's Mixer Node. Mixes a varaiadic list of AKNodes.
open class AKMixer: AKNode, AKToggleable, AKInput {
    /// The internal mixer node
    fileprivate var mixerAU = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: AUValue = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixerAU.outputVolume = volume
        }
    }

    /// Output Pan (Default 0 = center)
    @objc open dynamic var pan: AUValue = 1.0 {
        didSet {
            pan = min(pan, 1)
            pan = max(pan, -1)
            mixerAU.pan = pan
        }
    }

    fileprivate var lastKnownVolume: AUValue = 1.0

    /// Determine if the mixer is serving any output or if it is stopped.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the mixer node with no inputs, to be connected later
    @objc public init(volume: AUValue = 1.0) {
        super.init(avAudioNode: mixerAU, attach: true)
        self.volume = volume
    }

    /// Initialize the mixer node with multiple inputs
    ///
    /// - parameter inputs: A variadic list of AKNodes
    ///
    public convenience init(_ inputs: AKNode?...) {
        self.init(inputs.compactMap { $0 })
    }

    // swiftlint:enable force_unwrapping

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
